-- フィールドクリスタル出現システム
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Arena = Workspace:WaitForChild("Arena")

-- 設定
local CONFIG = {
	spawnInterval = {15, 30}, -- 出現間隔（秒）
	maxCrystals = 3, -- 最大同時出現数
	arenaRadius = 20, -- 出現範囲
	arenaHeight = 8, -- 出現高さ
	crystalValue = 1, -- 1個あたりの価値
}

-- 現在のクリスタル
local activeCrystals = {}

-- クリスタル作成（超巨大豪華版）
local function createCrystal(position)
	-- メインクリスタル（巨大）
	local crystal = Instance.new("Part")
	crystal.Name = "FieldCrystal"
	crystal.Size = Vector3.new(8, 12, 8)
	crystal.Position = position
	crystal.Anchored = true
	crystal.CanCollide = false
	crystal.Material = Enum.Material.Glass
	crystal.Color = Color3.fromRGB(50, 180, 255)
	crystal.Transparency = 0.15
	crystal.Reflectance = 0.6
	crystal.Parent = Arena

	-- ダイヤ形状（メッシュ）- 超大きく
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://9756362"
	mesh.Scale = Vector3.new(6, 9, 6)
	mesh.Parent = crystal

	-- 内側の光るコア（大きく）
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(3, 5, 3)
	core.Position = position
	core.Anchored = true
	core.CanCollide = false
	core.Material = Enum.Material.Neon
	core.Color = Color3.fromRGB(255, 255, 255)
	core.Parent = crystal

	local coreMesh = Instance.new("SpecialMesh")
	coreMesh.MeshType = Enum.MeshType.FileMesh
	coreMesh.MeshId = "rbxassetid://9756362"
	coreMesh.Scale = Vector3.new(2, 3, 2)
	coreMesh.Parent = core

	-- メインライト（非常に明るく）
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(100, 200, 255)
	light.Brightness = 8
	light.Range = 30
	light.Parent = crystal

	-- 追加ライト（虹色）
	local light2 = Instance.new("PointLight")
	light2.Color = Color3.fromRGB(255, 100, 255)
	light2.Brightness = 3
	light2.Range = 15
	light2.Parent = crystal

	-- キラキラパーティクル（大量）
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Name = "Sparkle"
	sparkle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 200, 255)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 100, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 200))
	})
	sparkle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 0)
	})
	sparkle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	sparkle.Lifetime = NumberRange.new(1.5, 3)
	sparkle.Rate = 40
	sparkle.Speed = NumberRange.new(3, 8)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.RotSpeed = NumberRange.new(-180, 180)
	sparkle.Parent = crystal

	-- 上昇するスターパーティクル
	local stars = Instance.new("ParticleEmitter")
	stars.Name = "Stars"
	stars.Texture = "rbxassetid://6490035152"
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 100))
	stars.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 1.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	stars.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	stars.Lifetime = NumberRange.new(2, 4)
	stars.Rate = 8
	stars.Speed = NumberRange.new(5, 10)
	stars.SpreadAngle = Vector2.new(30, 30)
	stars.EmissionDirection = Enum.NormalId.Top
	stars.LightEmission = 1
	stars.RotSpeed = NumberRange.new(-90, 90)
	stars.Parent = crystal

	-- 光の柱（複数、巨大）
	for i = 1, 3 do
		local beam = Instance.new("Part")
		beam.Name = "LightBeam" .. i
		beam.Size = Vector3.new(0.5 + i * 0.4, 80, 0.5 + i * 0.4)
		beam.Position = position + Vector3.new(0, 40, 0)
		beam.Anchored = true
		beam.CanCollide = false
		beam.Material = Enum.Material.Neon
		beam.Color = i == 1 and Color3.fromRGB(100, 200, 255) or
					  i == 2 and Color3.fromRGB(255, 100, 255) or
					  Color3.fromRGB(100, 255, 200)
		beam.Transparency = 0.5 + i * 0.1
		beam.Parent = crystal
	end

	-- 地面のリング（大きく）
	local ring = Instance.new("Part")
	ring.Name = "GroundRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.3, 16, 16)
	ring.CFrame = CFrame.new(position.X, position.Y - 4, position.Z) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(100, 200, 255)
	ring.Transparency = 0.4
	ring.Parent = crystal

	-- 外側のリング
	local outerRing = Instance.new("Part")
	outerRing.Name = "OuterRing"
	outerRing.Shape = Enum.PartType.Cylinder
	outerRing.Size = Vector3.new(0.2, 24, 24)
	outerRing.CFrame = CFrame.new(position.X, position.Y - 4, position.Z) * CFrame.Angles(0, 0, math.rad(90))
	outerRing.Anchored = true
	outerRing.CanCollide = false
	outerRing.Material = Enum.Material.Neon
	outerRing.Color = Color3.fromRGB(255, 100, 255)
	outerRing.Transparency = 0.6
	outerRing.Parent = crystal

	-- 回転アニメーション
	local rotationValue = Instance.new("NumberValue")
	rotationValue.Name = "Rotation"
	rotationValue.Value = 0
	rotationValue.Parent = crystal

	-- 回転と浮遊アニメーション
	task.spawn(function()
		local baseY = position.Y
		local time = 0
		while crystal and crystal.Parent do
			time = time + 0.05
			crystal.CFrame = CFrame.new(
				position.X,
				baseY + math.sin(time * 2) * 0.5,
				position.Z
			) * CFrame.Angles(0, time * 2, 0)
			task.wait(0.05)
		end
	end)

	-- タッチ検出
	crystal.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		if player and crystal and crystal.Parent then
			-- クリスタル獲得
			local Modules = ReplicatedStorage:WaitForChild("Modules")
			local PlayerData = require(Modules:WaitForChild("PlayerData"))
			local data = PlayerData.Get(player)

			if data then
				if not data.Crystals then
					data.Crystals = 0
				end
				data.Crystals = data.Crystals + CONFIG.crystalValue
				print("💎 " .. player.Name .. " がクリスタルを獲得! (合計: " .. data.Crystals .. ")")
			end

			-- 獲得エフェクト（豪華版）
			local effectPos = crystal.Position

			-- メイン爆発エフェクト
			local effect = Instance.new("Part")
			effect.Shape = Enum.PartType.Ball
			effect.Size = Vector3.new(3, 3, 3)
			effect.Position = effectPos
			effect.Anchored = true
			effect.CanCollide = false
			effect.Material = Enum.Material.Neon
			effect.Color = Color3.fromRGB(100, 200, 255)
			effect.Transparency = 0
			effect.Parent = Workspace

			-- 輝くリング
			local ring = Instance.new("Part")
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.5, 3, 3)
			ring.CFrame = CFrame.new(effectPos) * CFrame.Angles(0, 0, math.rad(90))
			ring.Anchored = true
			ring.CanCollide = false
			ring.Material = Enum.Material.Neon
			ring.Color = Color3.fromRGB(255, 255, 255)
			ring.Transparency = 0.3
			ring.Parent = Workspace

			task.spawn(function()
				for i = 1, 15 do
					effect.Size = effect.Size + Vector3.new(1.5, 1.5, 1.5)
					effect.Transparency = effect.Transparency + 0.07
					ring.Size = ring.Size + Vector3.new(0, 2, 2)
					ring.Transparency = ring.Transparency + 0.05
					task.wait(0.02)
				end
				effect:Destroy()
				ring:Destroy()
			end)

			-- 上昇する光パーティクル
			for j = 1, 8 do
				local particle = Instance.new("Part")
				particle.Shape = Enum.PartType.Ball
				particle.Size = Vector3.new(0.5, 0.5, 0.5)
				particle.Position = effectPos + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
				particle.Anchored = true
				particle.CanCollide = false
				particle.Material = Enum.Material.Neon
				particle.Color = Color3.fromRGB(200, 255, 255)
				particle.Parent = Workspace

				task.spawn(function()
					for k = 1, 20 do
						particle.Position = particle.Position + Vector3.new(0, 0.5, 0)
						particle.Size = particle.Size * 0.95
						particle.Transparency = particle.Transparency + 0.05
						task.wait(0.02)
					end
					particle:Destroy()
				end)
			end

			-- クリスタル削除
			local index = table.find(activeCrystals, crystal)
			if index then
				table.remove(activeCrystals, index)
			end
			crystal:Destroy()
		end
	end)

	return crystal
end

-- ランダム位置を取得
local function getRandomPosition()
	local angle = math.random() * math.pi * 2
	local radius = math.random() * CONFIG.arenaRadius
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius
	return Vector3.new(x, CONFIG.arenaHeight, z)
end

-- クリスタルを出現させる
local function spawnCrystal()
	if #activeCrystals >= CONFIG.maxCrystals then return end

	local position = getRandomPosition()
	local crystal = createCrystal(position)
	table.insert(activeCrystals, crystal)

	print("💎 クリスタル出現! (現在: " .. #activeCrystals .. "/" .. CONFIG.maxCrystals .. ")")
end

-- スポーンループ
task.spawn(function()
	while true do
		local interval = math.random(CONFIG.spawnInterval[1], CONFIG.spawnInterval[2])
		task.wait(interval)

		-- プレイヤーがいる場合のみ出現
		if #Players:GetPlayers() > 0 then
			spawnCrystal()
		end
	end
end)

-- 初期クリスタル
task.wait(5)
spawnCrystal()

print("💎 クリスタルスポーナー起動")
print("   出現間隔: " .. CONFIG.spawnInterval[1] .. "〜" .. CONFIG.spawnInterval[2] .. "秒")
print("   最大同時出現: " .. CONFIG.maxCrystals .. "個")
