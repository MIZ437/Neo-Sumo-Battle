-- Neo Sumo Battle - プレイヤーデータ管理（強化システム追加）
local PlayerData = {}
PlayerData.__index = PlayerData

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = ReplicatedStorage:WaitForChild("Config")
local GameConfig = require(Config:WaitForChild("GameConfig"))

local players = {}

function PlayerData.new(player)
	local self = setmetatable({}, PlayerData)

	self.Player = player
	self.Level = 1
	self.Exp = 0
	self.Coins = 100  -- 初期コイン
	self.Crystals = 0
	self.MaxStageCleared = 0
	self.EquippedSkill = 1

	-- 強化レベル
	self.Upgrades = {
		HP = 0,
		Power = 0,
		Stability = 0,
		Speed = 0,
	}

	self.Stats = {
		HP = GameConfig.BaseStats.HP,
		MaxHP = GameConfig.BaseStats.HP,
		Power = GameConfig.BaseStats.Power,
		Stability = GameConfig.BaseStats.Stability,
		Speed = GameConfig.BaseStats.Speed,
		Jump = GameConfig.BaseStats.Jump,
		Guard = GameConfig.BaseStats.Guard,
		Stamina = GameConfig.BaseStats.Stamina,
		MaxStamina = GameConfig.BaseStats.Stamina,
		StaminaRegen = 10,
		SP = 0,
		MaxSP = GameConfig.BaseStats.SP,
		SPRegen = 5,
	}

	self.State = {
		InBattle = false,
		IsGuarding = false,
		IsDodging = false,
		IsExhausted = false,
		IsInvincible = false,
		ActiveSkillEffects = {},
	}

	self.Cooldowns = {
		Push = 0,
		Dodge = 0,
		Skill = 0,
	}

	players[player] = self
	return self
end

function PlayerData.Get(player)
	return players[player]
end

function PlayerData.Remove(player)
	players[player] = nil
end

-- ステータス計算（レベル + 強化ボーナス適用）
function PlayerData:ApplyLevelStats()
	local baseStats = GameConfig.BaseStats
	local levelBonus = (self.Level - 1) * 2

	-- レベルボーナス + 強化ボーナス
	local hpUpgrade = self.Upgrades.HP * GameConfig.Upgrades.HP.effect
	local powerUpgrade = self.Upgrades.Power * GameConfig.Upgrades.Power.effect
	local stabilityUpgrade = self.Upgrades.Stability * GameConfig.Upgrades.Stability.effect
	local speedUpgrade = self.Upgrades.Speed * GameConfig.Upgrades.Speed.effect

	self.Stats.MaxHP = baseStats.HP + (levelBonus * 5) + hpUpgrade
	self.Stats.HP = self.Stats.MaxHP
	self.Stats.Power = baseStats.Power + levelBonus + powerUpgrade
	self.Stats.Stability = baseStats.Stability + levelBonus + stabilityUpgrade
	self.Stats.Speed = baseStats.Speed + speedUpgrade
	self.Stats.Jump = baseStats.Jump
	self.Stats.Guard = baseStats.Guard
	self.Stats.MaxStamina = baseStats.Stamina
	self.Stats.Stamina = self.Stats.MaxStamina
	self.Stats.MaxSP = baseStats.SP
	self.Stats.SP = 0
end

function PlayerData:ResetBattleState()
	self:ApplyLevelStats()
	self.Stats.HP = self.Stats.MaxHP
	self.Stats.SP = 0
	self.Stats.Stamina = self.Stats.MaxStamina

	self.State = {
		InBattle = false,
		IsGuarding = false,
		IsDodging = false,
		IsExhausted = false,
		IsInvincible = false,
		ActiveSkillEffects = {},
	}
	self.Cooldowns = {Push = 0, Dodge = 0, Skill = 0}
end

function PlayerData:AddExp(amount)
	self.Exp = self.Exp + amount
	local expNeeded = 100 * (1.2 ^ (self.Level - 1))

	while self.Exp >= expNeeded do
		self.Exp = self.Exp - expNeeded
		self.Level = self.Level + 1
		expNeeded = 100 * (1.2 ^ (self.Level - 1))
		self:ApplyLevelStats()
		print("レベルアップ! Lv." .. self.Level)
	end
end

-- 強化関数
function PlayerData:UpgradeStat(statName)
	local upgradeConfig = GameConfig.Upgrades[statName]
	if not upgradeConfig then
		return false, "無効なステータス"
	end

	local currentLevel = self.Upgrades[statName]
	if currentLevel >= upgradeConfig.maxLevel then
		return false, "最大レベルに達しています"
	end

	local cost = GameConfig.GetUpgradeCost(statName, currentLevel)
	if self.Coins < cost then
		return false, "コインが足りません"
	end

	-- 強化実行
	self.Coins = self.Coins - cost
	self.Upgrades[statName] = currentLevel + 1
	self:ApplyLevelStats()

	print(statName .. " 強化! Lv." .. self.Upgrades[statName])
	return true, "強化成功"
end

-- 強化情報取得
function PlayerData:GetUpgradeInfo(statName)
	local upgradeConfig = GameConfig.Upgrades[statName]
	if not upgradeConfig then return nil end

	local currentLevel = self.Upgrades[statName]
	local cost = GameConfig.GetUpgradeCost(statName, currentLevel)
	local isMaxed = currentLevel >= upgradeConfig.maxLevel

	return {
		name = upgradeConfig.name,
		icon = upgradeConfig.icon,
		level = currentLevel,
		maxLevel = upgradeConfig.maxLevel,
		effect = upgradeConfig.effect,
		cost = cost,
		isMaxed = isMaxed,
	}
end

function PlayerData:UseStamina(amount)
	if self.Stats.Stamina < amount then
		return false
	end
	self.Stats.Stamina = self.Stats.Stamina - amount
	if self.Stats.Stamina <= 0 then
		self.Stats.Stamina = 0
		self.State.IsExhausted = true
	end
	return true
end

function PlayerData:UseSP(percentage)
	local cost = self.Stats.MaxSP * (percentage / 100)
	if self.Stats.SP < cost then
		return false
	end
	self.Stats.SP = self.Stats.SP - cost
	return true
end

function PlayerData:TakeDamage(damage, knockback)
	if self.State.IsInvincible then
		return 0
	end
	local actualDamage = damage
	if self.State.IsGuarding then
		actualDamage = damage * (1 - self.Stats.Guard / 100)
		knockback = knockback * 0.3
	end
	actualDamage = actualDamage * (1 - self.Stats.Stability / 200)
	self.Stats.HP = math.max(0, self.Stats.HP - actualDamage)
	return actualDamage, knockback
end

return PlayerData
