-- 敵AIモジュール（攻撃機能強化版）

local EnemyAI = {}
EnemyAI.__index = EnemyAI

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local EnemyConfig = require(Config:WaitForChild("EnemyConfig"))
local GameConfig = require(Config:WaitForChild("GameConfig"))

local Events = ReplicatedStorage:WaitForChild("Events")
local DamageDealt = Events:WaitForChild("DamageDealt")

function EnemyAI.new(enemy)
	local self = setmetatable({}, EnemyAI)

	self.Enemy = enemy
	self.EnemyData = enemy:FindFirstChild("EnemyData")
	self.Humanoid = enemy:FindFirstChild("Humanoid")
	self.RootPart = enemy:FindFirstChild("HumanoidRootPart")

	-- AI設定
	self.Accuracy = self.EnemyData and self.EnemyData:FindFirstChild("Accuracy") and self.EnemyData.Accuracy.Value or 0.5
	self.TypeName = self.EnemyData and self.EnemyData:FindFirstChild("Type") and self.EnemyData.Type.Value or "万能型"

	-- AIタイプ決定
	self.Goal = "Smart"
	self.Style = "Balanced"

	for _, typeData in ipairs(EnemyConfig.Types) do
		if typeData.name == self.TypeName then
			self.Goal = typeData.goal
			self.Style = typeData.style
			break
		end
	end

	self.StyleData = EnemyConfig.Styles[self.Style] or EnemyConfig.Styles.Balanced or {
		attackRate = 0.5,
		guardRate = 0.3,
		attackRange = 6,
		flankChance = 0.2,
		retreatThreshold = 0.3,
		speedMult = 1,
		aggressiveness = 0.5
	}

	-- 状態
	self.State = {
		isAttacking = false,
		isGuarding = false,
		target = nil,
		lastAttackTime = 0,
		actionCooldown = 0,
	}

	-- スピードタイプの場合は速度UP
	if self.StyleData and self.StyleData.speedMult and self.Humanoid then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed * self.StyleData.speedMult
	end

	self.Active = true

	return self
end

function EnemyAI:GetTarget()
	local closest = nil
	local closestDist = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local rootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and rootPart and self.RootPart then
				local dist = (rootPart.Position - self.RootPart.Position).Magnitude
				if dist < closestDist then
					closest = character
					closestDist = dist
				end
			end
		end
	end

	return closest, closestDist
end

function EnemyAI:GetArenaCenter()
	return Vector3.new(0, 7, 0)
end

function EnemyAI:GetDistanceFromEdge()
	if not self.RootPart then return 999 end
	local center = self:GetArenaCenter()
	local pos2D = Vector3.new(self.RootPart.Position.X, 0, self.RootPart.Position.Z)
	local center2D = Vector3.new(center.X, 0, center.Z)
	local distFromCenter = (pos2D - center2D).Magnitude
	local radius = GameConfig.ArenaRadius or 25
	return radius - distFromCenter
end

function EnemyAI:ShouldAttack()
	-- 精度判定
	if math.random() > self.Accuracy then
		return false
	end
	return math.random() < self.StyleData.attackRate
end

function EnemyAI:ShouldGuard()
	if math.random() > self.Accuracy then
		return false
	end
	return math.random() < self.StyleData.guardRate
end

function EnemyAI:Attack(target)
	if self.State.isAttacking then return end
	if not target or not self.RootPart then return end

	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	local distance = (targetRoot.Position - self.RootPart.Position).Magnitude
	if distance > 6 then return end -- 攻撃範囲外

	-- 攻撃クールダウンチェック
	if tick() - self.State.lastAttackTime < 0.8 then return end

	self.State.isAttacking = true
	self.State.lastAttackTime = tick()

	-- ノックバック方向
	local direction = (targetRoot.Position - self.RootPart.Position).Unit
	direction = Vector3.new(direction.X, 0.3, direction.Z).Unit

	-- 攻撃力（ステージに応じて上昇、バランス調整済み）
	local stage = self.EnemyData and self.EnemyData:FindFirstChild("Stage") and self.EnemyData.Stage.Value or 1
	-- ダメージとノックバックを低減
	local damage = GameConfig.Push.Damage * (0.6 + stage * 0.05)
	local knockback = GameConfig.Push.Knockback * (0.5 + stage * 0.03)

	-- プレイヤーのガード状態をチェック
	local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(target)
	if targetPlayer then
		local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
		local PlayerData = require(Modules:WaitForChild("PlayerData"))
		local data = PlayerData.Get(targetPlayer)
		if data and data.State and data.State.IsGuarding then
			-- ガード中はダメージ70%軽減、ノックバック50%軽減
			damage = damage * 0.3
			knockback = knockback * 0.5
			print("Player GUARDING! Damage reduced")
		end
	end

	-- プレイヤーにダメージ＆ノックバック適用
	DamageDealt:FireAllClients(target, damage, direction * knockback)

	-- 攻撃エフェクト（敵側）
	self:PlayAttackEffect()

	task.delay(0.5, function()
		self.State.isAttacking = false
	end)
end

function EnemyAI:PlayAttackEffect()
	if not self.RootPart then return end

	-- 攻撃エフェクト（赤い球）
	local effect = Instance.new("Part")
	effect.Shape = Enum.PartType.Ball
	effect.Size = Vector3.new(2, 2, 2)
	effect.Position = self.RootPart.Position + self.RootPart.CFrame.LookVector * 2
	effect.Anchored = true
	effect.CanCollide = false
	effect.Material = Enum.Material.Neon
	effect.Color = Color3.fromRGB(255, 100, 100)
	effect.Transparency = 0.3
	effect.Parent = workspace

	-- エフェクトを消す
	task.spawn(function()
		for i = 1, 10 do
			effect.Size = effect.Size + Vector3.new(0.3, 0.3, 0.3)
			effect.Transparency = effect.Transparency + 0.07
			task.wait(0.02)
		end
		effect:Destroy()
	end)
end

function EnemyAI:Chase(target)
	if not target or not self.Humanoid then return end
	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	self.Humanoid:MoveTo(targetRoot.Position)
end

function EnemyAI:Flank(target)
	if not target or not self.Humanoid or not self.RootPart then return end
	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	local toTarget = (targetRoot.Position - self.RootPart.Position).Unit
	local perpendicular = Vector3.new(-toTarget.Z, 0, toTarget.X)
	local flankPos = targetRoot.Position + perpendicular * 8

	self.Humanoid:MoveTo(flankPos)
end

function EnemyAI:Guard()
	self.State.isGuarding = true
	task.delay(1, function()
		self.State.isGuarding = false
	end)
end

function EnemyAI:Retreat()
	if not self.Humanoid then return end
	local center = self:GetArenaCenter()
	self.Humanoid:MoveTo(center)
end

function EnemyAI:DecideAction(target, distance)
	local arenaEdgeDist = self:GetDistanceFromEdge()

	-- 崖際で危険な場合
	if arenaEdgeDist < 5 then
		return "retreat"
	end

	-- 攻撃範囲内なら積極的に攻撃
	if distance < 6 then
		if self:ShouldAttack() then
			return "attack"
		elseif self:ShouldGuard() then
			return "guard"
		end
	end

	-- 目的別行動
	if self.Goal == "Killer" then
		if distance < 6 and self:ShouldAttack() then
			return "attack"
		else
			return "chase"
		end

	elseif self.Goal == "Pusher" then
		local targetRoot = target:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local arenaRadius = GameConfig.ArenaRadius or 25
			local targetEdgeDist = arenaRadius -
				Vector3.new(targetRoot.Position.X, 0, targetRoot.Position.Z).Magnitude

			if targetEdgeDist < 8 and distance < 6 then
				return "attack"
			end
		end

		if distance < 6 then
			return "attack"
		else
			return "flank"
		end

	else -- Smart
		local targetHumanoid = target:FindFirstChild("Humanoid")
		local targetHP = targetHumanoid and targetHumanoid.Health or 100

		if targetHP < 30 or distance < 6 then
			return "attack"
		elseif arenaEdgeDist > 15 then
			return "chase"
		else
			if self:ShouldGuard() then
				return "guard"
			else
				return "chase"
			end
		end
	end

	return "chase" -- デフォルトは追跡
end

function EnemyAI:Update(dt)
	if not self.Active then return end
	if not self.RootPart or not self.Humanoid then return end

	-- クールダウン減少
	self.State.actionCooldown = math.max(0, self.State.actionCooldown - dt)
	if self.State.actionCooldown > 0 then return end

	local target, distance = self:GetTarget()
	if not target then return end

	local action = self:DecideAction(target, distance)

	if action == "attack" then
		self:Attack(target)
		self.State.actionCooldown = 0.3
	elseif action == "chase" then
		self:Chase(target)
		self.State.actionCooldown = 0.2
	elseif action == "flank" then
		self:Flank(target)
		self.State.actionCooldown = 0.3
	elseif action == "guard" then
		self:Guard()
		self.State.actionCooldown = 0.5
	elseif action == "retreat" then
		self:Retreat()
		self.State.actionCooldown = 0.2
	end
end

function EnemyAI:TakeDamage(damage, knockback)
	if self.State.isGuarding then
		damage = damage * 0.5
		knockback = knockback * 0.3
	end

	if not self.EnemyData then return false end

	local hp = self.EnemyData.HP.Value
	hp = math.max(0, hp - damage)
	self.EnemyData.HP.Value = hp

	-- ノックバック適用
	if knockback and self.RootPart then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = knockback
		bodyVelocity.Parent = self.RootPart

		task.delay(0.2, function()
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity:Destroy()
			end
		end)
	end

	return hp <= 0
end

function EnemyAI:Destroy()
	self.Active = false
end

return EnemyAI
