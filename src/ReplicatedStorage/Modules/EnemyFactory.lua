-- 敵キャラクター生成モジュール（人型対応版）
local EnemyFactory = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = ReplicatedStorage:WaitForChild("Config")
local EnemyConfig = require(Config:WaitForChild("EnemyConfig"))
local GameConfig = require(Config:WaitForChild("GameConfig"))

-- 人型キャラクター生成（通常敵用）
function EnemyFactory.CreateHumanoid(name, color, position)
	local model = Instance.new("Model")
	model.Name = name or "Enemy"

	-- HumanoidRootPart
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Position = position + Vector3.new(0, 3, 0)
	rootPart.Transparency = 1
	rootPart.Anchored = false
	rootPart.CanCollide = false
	rootPart.Parent = model

	-- 胴体
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = position + Vector3.new(0, 3, 0)
	torso.Anchored = false
	torso.Material = Enum.Material.SmoothPlastic
	torso.Color = color or Color3.fromRGB(100, 150, 100)
	torso.Parent = model

	-- 頭
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Position = position + Vector3.new(0, 4.6, 0)
	head.Anchored = false
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(245, 205, 170) -- 肌色
	head.Parent = model

	-- 顔（デカール）
	local face = Instance.new("Decal")
	face.Name = "face"
	face.Texture = "rbxassetid://7075502432" -- 標準顔
	face.Face = Enum.NormalId.Front
	face.Parent = head

	-- 左腕
	local leftArm = Instance.new("Part")
	leftArm.Name = "Left Arm"
	leftArm.Size = Vector3.new(1, 2, 1)
	leftArm.Position = position + Vector3.new(-1.5, 3, 0)
	leftArm.Anchored = false
	leftArm.Material = Enum.Material.SmoothPlastic
	leftArm.Color = color or Color3.fromRGB(100, 150, 100)
	leftArm.Parent = model

	-- 右腕
	local rightArm = Instance.new("Part")
	rightArm.Name = "Right Arm"
	rightArm.Size = Vector3.new(1, 2, 1)
	rightArm.Position = position + Vector3.new(1.5, 3, 0)
	rightArm.Anchored = false
	rightArm.Material = Enum.Material.SmoothPlastic
	rightArm.Color = color or Color3.fromRGB(100, 150, 100)
	rightArm.Parent = model

	-- 左脚
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "Left Leg"
	leftLeg.Size = Vector3.new(1, 2, 1)
	leftLeg.Position = position + Vector3.new(-0.5, 1, 0)
	leftLeg.Anchored = false
	leftLeg.Material = Enum.Material.SmoothPlastic
	leftLeg.Color = Color3.fromRGB(50, 50, 100) -- ズボン色
	leftLeg.Parent = model

	-- 右脚
	local rightLeg = Instance.new("Part")
	rightLeg.Name = "Right Leg"
	rightLeg.Size = Vector3.new(1, 2, 1)
	rightLeg.Position = position + Vector3.new(0.5, 1, 0)
	rightLeg.Anchored = false
	rightLeg.Material = Enum.Material.SmoothPlastic
	rightLeg.Color = Color3.fromRGB(50, 50, 100)
	rightLeg.Parent = model

	model.PrimaryPart = rootPart

	-- パーツを接続
	local function weld(part1, part2)
		local w = Instance.new("WeldConstraint")
		w.Part0 = part1
		w.Part1 = part2
		w.Parent = part1
	end

	weld(rootPart, torso)
	weld(torso, head)
	weld(torso, leftArm)
	weld(torso, rightArm)
	weld(torso, leftLeg)
	weld(torso, rightLeg)

	-- Humanoid追加
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.WalkSpeed = 14
	humanoid.JumpPower = 50
	humanoid.Parent = model

	-- 敵データ
	local enemyData = Instance.new("Folder")
	enemyData.Name = "EnemyData"
	enemyData.Parent = model

	local hpValue = Instance.new("NumberValue")
	hpValue.Name = "HP"
	hpValue.Value = 100
	hpValue.Parent = enemyData

	local maxHpValue = Instance.new("NumberValue")
	maxHpValue.Name = "MaxHP"
	maxHpValue.Value = 100
	maxHpValue.Parent = enemyData

	local typeValue = Instance.new("StringValue")
	typeValue.Name = "Type"
	typeValue.Value = ""
	typeValue.Parent = enemyData

	return model
end

-- ゴーレム生成（ボス用）
function EnemyFactory.CreateGolem(name, color, scale, position)
	scale = scale or 1
	local baseSize = 2 * scale

	local model = Instance.new("Model")
	model.Name = name or "Golem"

	-- 胴体
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(baseSize * 2, baseSize * 2.5, baseSize)
	torso.Position = position + Vector3.new(0, baseSize * 2, 0)
	torso.Anchored = false
	torso.CanCollide = true
	torso.Material = Enum.Material.Rock
	torso.Color = color or Color3.fromRGB(100, 150, 100)
	torso.Parent = model

	-- 頭
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(baseSize * 1.5, baseSize * 1.5, baseSize * 1.5)
	head.Position = position + Vector3.new(0, baseSize * 4, 0)
	head.Anchored = false
	head.Material = Enum.Material.Rock
	head.Color = color or Color3.fromRGB(100, 150, 100)
	head.Parent = model

	-- 目（左右）
	local leftEye = Instance.new("Part")
	leftEye.Name = "LeftEye"
	leftEye.Size = Vector3.new(baseSize * 0.3, baseSize * 0.3, baseSize * 0.1)
	leftEye.Position = head.Position + Vector3.new(-baseSize * 0.3, 0, baseSize * 0.7)
	leftEye.Anchored = false
	leftEye.Material = Enum.Material.Neon
	leftEye.Color = Color3.fromRGB(255, 255, 0)
	leftEye.Parent = model

	local rightEye = Instance.new("Part")
	rightEye.Name = "RightEye"
	rightEye.Size = Vector3.new(baseSize * 0.3, baseSize * 0.3, baseSize * 0.1)
	rightEye.Position = head.Position + Vector3.new(baseSize * 0.3, 0, baseSize * 0.7)
	rightEye.Anchored = false
	rightEye.Material = Enum.Material.Neon
	rightEye.Color = Color3.fromRGB(255, 255, 0)
	rightEye.Parent = model

	-- 腕
	local leftArm = Instance.new("Part")
	leftArm.Name = "LeftArm"
	leftArm.Size = Vector3.new(baseSize * 0.8, baseSize * 2.5, baseSize * 0.8)
	leftArm.Position = position + Vector3.new(-baseSize * 1.5, baseSize * 2, 0)
	leftArm.Anchored = false
	leftArm.Material = Enum.Material.Rock
	leftArm.Color = color or Color3.fromRGB(100, 150, 100)
	leftArm.Parent = model

	local rightArm = Instance.new("Part")
	rightArm.Name = "RightArm"
	rightArm.Size = Vector3.new(baseSize * 0.8, baseSize * 2.5, baseSize * 0.8)
	rightArm.Position = position + Vector3.new(baseSize * 1.5, baseSize * 2, 0)
	rightArm.Anchored = false
	rightArm.Material = Enum.Material.Rock
	rightArm.Color = color or Color3.fromRGB(100, 150, 100)
	rightArm.Parent = model

	-- 脚
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "LeftLeg"
	leftLeg.Size = Vector3.new(baseSize * 0.9, baseSize * 2, baseSize * 0.9)
	leftLeg.Position = position + Vector3.new(-baseSize * 0.5, baseSize * 0.5, 0)
	leftLeg.Anchored = false
	leftLeg.Material = Enum.Material.Rock
	leftLeg.Color = color or Color3.fromRGB(100, 150, 100)
	leftLeg.Parent = model

	local rightLeg = Instance.new("Part")
	rightLeg.Name = "RightLeg"
	rightLeg.Size = Vector3.new(baseSize * 0.9, baseSize * 2, baseSize * 0.9)
	rightLeg.Position = position + Vector3.new(baseSize * 0.5, baseSize * 0.5, 0)
	rightLeg.Anchored = false
	rightLeg.Material = Enum.Material.Rock
	rightLeg.Color = color or Color3.fromRGB(100, 150, 100)
	rightLeg.Parent = model

	-- HumanoidRootPart
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(baseSize * 2, baseSize * 2, baseSize)
	rootPart.Position = position + Vector3.new(0, baseSize * 2, 0)
	rootPart.Transparency = 1
	rootPart.Anchored = false
	rootPart.CanCollide = false
	rootPart.Parent = model

	model.PrimaryPart = rootPart

	-- 接続
	local function weld(part1, part2)
		local w = Instance.new("WeldConstraint")
		w.Part0 = part1
		w.Part1 = part2
		w.Parent = part1
	end

	weld(rootPart, torso)
	weld(torso, head)
	weld(torso, leftArm)
	weld(torso, rightArm)
	weld(torso, leftLeg)
	weld(torso, rightLeg)
	weld(head, leftEye)
	weld(head, rightEye)

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.WalkSpeed = 10
	humanoid.JumpPower = 0
	humanoid.Parent = model

	-- 敵データ
	local enemyData = Instance.new("Folder")
	enemyData.Name = "EnemyData"
	enemyData.Parent = model

	local hpValue = Instance.new("NumberValue")
	hpValue.Name = "HP"
	hpValue.Value = 100
	hpValue.Parent = enemyData

	local maxHpValue = Instance.new("NumberValue")
	maxHpValue.Name = "MaxHP"
	maxHpValue.Value = 100
	maxHpValue.Parent = enemyData

	local typeValue = Instance.new("StringValue")
	typeValue.Name = "Type"
	typeValue.Value = ""
	typeValue.Parent = enemyData

	return model
end

-- 通常敵生成（人型）
function EnemyFactory.CreateStageEnemy(stage, position)
	local difficulty = EnemyConfig.GetDifficulty(stage)
	local enemyType = EnemyConfig.GetRandomType()

	local baseStats = GameConfig.BaseStats
	local hp = baseStats.HP * difficulty.statMultiplier

	-- テーマカラー（草原は緑系）
	local color = Color3.fromRGB(100, 150, 100)

	-- 人型キャラクターを生成
	local enemy = EnemyFactory.CreateHumanoid(
		"敵 Lv." .. stage,
		color,
		position
	)

	-- ステータス設定
	local enemyData = enemy:FindFirstChild("EnemyData")
	enemyData.HP.Value = hp
	enemyData.MaxHP.Value = hp
	enemyData.Type.Value = enemyType.name

	-- 難易度情報
	local accuracyValue = Instance.new("NumberValue")
	accuracyValue.Name = "Accuracy"
	accuracyValue.Value = difficulty.accuracy
	accuracyValue.Parent = enemyData

	local stageValue = Instance.new("IntValue")
	stageValue.Name = "Stage"
	stageValue.Value = stage
	stageValue.Parent = enemyData

	return enemy
end

-- ボス生成（ゴーレム）
function EnemyFactory.CreateBoss(bossType, position)
	local color, scale, hp

	if bossType == "GrassGolem" then
		color = Color3.fromRGB(50, 120, 50)
		scale = 2
		hp = 500
	end

	local boss = EnemyFactory.CreateGolem(
		"草ゴーレム",
		color,
		scale,
		position
	)

	local enemyData = boss:FindFirstChild("EnemyData")
	enemyData.HP.Value = hp
	enemyData.MaxHP.Value = hp

	local isBoss = Instance.new("BoolValue")
	isBoss.Name = "IsBoss"
	isBoss.Value = true
	isBoss.Parent = enemyData

	return boss
end

return EnemyFactory
