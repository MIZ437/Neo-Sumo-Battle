-- Neo Sumo Battle - ゲーム設定（強化システム追加）
local GameConfig = {}

-- 基本ステータス
GameConfig.BaseStats = {
	HP = 100,
	MaxHP = 100,
	Power = 10,
	Stability = 10,
	Speed = 16,
	Jump = 50,
	Guard = 0.5,
	Stamina = 100,
	MaxStamina = 100,
	StaminaRegen = 10,
	SP = 0,
	MaxSP = 100,
	SPRegen = 5,
}

-- 押し攻撃設定
GameConfig.Push = {
	Range = 5,
	Damage = 10,
	Knockback = 30,
	Cooldown = 0.3,
}

-- 回避設定
GameConfig.Dodge = {
	Distance = 8,
	Duration = 0.2,
	InvincibleTime = 0.15,
}

-- スタミナ消費
GameConfig.StaminaCost = {
	PushHit = 8,
	PushMiss = 5,
	Guard = 3,
	Dodge = 15,
}

-- バトル設定
GameConfig.MatchTime = 120
GameConfig.FallHeight = -20

-- 強化システム設定
GameConfig.Upgrades = {
	HP = {
		name = "HP強化",
		icon = "heart",
		effect = 10,           -- 1回の強化で+10
		baseCost = 50,         -- 初回コスト
		costIncrease = 25,     -- コスト増加量
		maxLevel = 10,         -- 最大強化回数
	},
	Power = {
		name = "攻撃力強化",
		icon = "sword",
		effect = 2,
		baseCost = 100,
		costIncrease = 50,
		maxLevel = 10,
	},
	Stability = {
		name = "安定性強化",
		icon = "shield",
		effect = 2,
		baseCost = 100,
		costIncrease = 50,
		maxLevel = 10,
	},
	Speed = {
		name = "速度強化",
		icon = "wind",
		effect = 1,
		baseCost = 150,
		costIncrease = 75,
		maxLevel = 5,
	},
	Guard = {
		name = "ガード強化",
		icon = "shield2",
		effect = 0.05,         -- ガード軽減率+5%
		baseCost = 120,
		costIncrease = 60,
		maxLevel = 8,
	},
	Stamina = {
		name = "スタミナ強化",
		icon = "energy",
		effect = 10,           -- 最大スタミナ+10
		baseCost = 80,
		costIncrease = 40,
		maxLevel = 10,
	},
	Jump = {
		name = "ジャンプ強化",
		icon = "arrow_up",
		effect = 5,            -- ジャンプ力+5
		baseCost = 100,
		costIncrease = 50,
		maxLevel = 5,
	},
}

-- 強化コスト計算
function GameConfig.GetUpgradeCost(statName, currentLevel)
	local upgrade = GameConfig.Upgrades[statName]
	if not upgrade then return 999999 end
	if currentLevel >= upgrade.maxLevel then return -1 end -- 最大レベル
	return upgrade.baseCost + (currentLevel * upgrade.costIncrease)
end

return GameConfig
