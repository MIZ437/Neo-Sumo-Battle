-- プレイヤーダメージ処理（被ダメージ記録対応版）
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local DamageDealt = Events:WaitForChild("DamageDealt")

-- PlayerDamagedイベント取得（サーバーに被ダメージを通知）
local PlayerDamaged = Events:WaitForChild("PlayerDamaged", 5)

-- ダメージフラッシュエフェクト
local function showDamageFlash()
	local playerGui = player:WaitForChild("PlayerGui")

	local damageFlash = Instance.new("Frame")
	damageFlash.Name = "DamageFlash"
	damageFlash.Size = UDim2.new(1, 0, 1, 0)
	damageFlash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	damageFlash.BackgroundTransparency = 0.6
	damageFlash.BorderSizePixel = 0
	damageFlash.ZIndex = 100
	damageFlash.Parent = playerGui

	local tween = TweenService:Create(damageFlash, TweenInfo.new(0.2), {
		BackgroundTransparency = 1
	})
	tween:Play()

	tween.Completed:Connect(function()
		damageFlash:Destroy()
	end)
end

-- ダメージ数値表示
local function showDamageNumber(position, damage, isPlayer)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.Adornee = nil
	billboard.AlwaysOnTop = true

	local part = Instance.new("Part")
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position + Vector3.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = workspace

	billboard.Adornee = part
	billboard.Parent = part

	local damageLabel = Instance.new("TextLabel")
	damageLabel.Size = UDim2.new(1, 0, 1, 0)
	damageLabel.BackgroundTransparency = 1
	damageLabel.Text = "-" .. math.floor(damage)
	-- プレイヤーへのダメージは赤、敵へのダメージは黄色
	damageLabel.TextColor3 = isPlayer and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 100)
	damageLabel.TextSize = isPlayer and 28 or 24
	damageLabel.Font = Enum.Font.GothamBold
	damageLabel.TextStrokeTransparency = 0.5
	damageLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	damageLabel.Parent = billboard

	-- 上に浮いていくアニメーション
	task.spawn(function()
		for i = 1, 20 do
			part.Position = part.Position + Vector3.new(0, 0.1, 0)
			damageLabel.TextTransparency = damageLabel.TextTransparency + 0.05
			damageLabel.TextStrokeTransparency = damageLabel.TextStrokeTransparency + 0.05
			task.wait(0.03)
		end
		part:Destroy()
	end)
end

-- ダメージ受信
DamageDealt.OnClientEvent:Connect(function(target, damage, knockback)
	local character = player.Character
	if not character then return end

	-- 自分が対象の場合
	if target == character then
		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoid and rootPart then
			-- ダメージ適用
			humanoid:TakeDamage(damage)

			-- 被ダメージをサーバーに通知
			if PlayerDamaged then
				PlayerDamaged:FireServer(damage)
			end

			-- ダメージエフェクト
			showDamageFlash()
			showDamageNumber(rootPart.Position, damage, true)

			-- ノックバック適用
			if knockback then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bodyVelocity.Velocity = knockback
				bodyVelocity.Parent = rootPart

				task.delay(0.2, function()
					if bodyVelocity and bodyVelocity.Parent then
						bodyVelocity:Destroy()
					end
				end)
			end
		end
	end

	-- 敵がダメージを受けた場合
	if target and target:FindFirstChild("EnemyData") then
		local enemyRoot = target:FindFirstChild("HumanoidRootPart")
		if enemyRoot then
			showDamageNumber(enemyRoot.Position, damage, false)
		end
	end
end)

print("ダメージハンドラー起動（被ダメージ記録対応版）")
