-- カウントダウン処理（フォールバックサウンド対応）
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local battleUI = playerGui:WaitForChild("BattleUI")
local mainFrame = battleUI:WaitForChild("MainFrame")
local countdownFrame = mainFrame:WaitForChild("CountdownFrame")
local countdownLabel = countdownFrame:WaitForChild("CountdownLabel")

local Events = ReplicatedStorage:WaitForChild("Events")
local Countdown = Events:WaitForChild("Countdown")
local BattleReady = Events:WaitForChild("BattleReady")

print("カウントダウンコントローラー初期化")

-- サウンド取得
local gameSounds = Workspace:WaitForChild("GameSounds", 5)
local countdownSound = gameSounds and gameSounds:FindFirstChild("CountdownSound")
local startSound = gameSounds and gameSounds:FindFirstChild("StartSound")
local backupCount = gameSounds and gameSounds:FindFirstChild("BackupCountdownSound")
local backupStart = gameSounds and gameSounds:FindFirstChild("BackupStartSound")

-- サウンド再生（フォールバック付き）
local function playCountdownSound()
	-- メインサウンドを試す
	if countdownSound then
		local clone = countdownSound:Clone()
		clone.Parent = playerGui

		local success = pcall(function()
			clone:Play()
		end)

		if success and clone.IsPlaying then
			print("メインカウント音再生")
			task.delay(1, function() clone:Destroy() end)
			return
		else
			clone:Destroy()
		end
	end

	-- バックアップを試す
	if backupCount then
		local clone = backupCount:Clone()
		clone.Parent = playerGui
		clone:Play()
		print("バックアップカウント音再生")
		task.delay(1, function() clone:Destroy() end)
	end
end

local function playStartSound()
	if startSound then
		local clone = startSound:Clone()
		clone.Parent = playerGui

		local success = pcall(function()
			clone:Play()
		end)

		if success and clone.IsPlaying then
			print("メインスタート音再生")
			task.delay(2, function() clone:Destroy() end)
			return
		else
			clone:Destroy()
		end
	end

	if backupStart then
		local clone = backupStart:Clone()
		clone.Parent = playerGui
		clone:Play()
		print("バックアップスタート音再生")
		task.delay(2, function() clone:Destroy() end)
	end
end

-- カウントダウン受信
Countdown.OnClientEvent:Connect(function(count)
	print("カウントダウン: " .. count)
	countdownFrame.Visible = true

	if count == 0 then
		countdownLabel.Text = "START!"
		countdownLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
		countdownLabel.TextSize = 50
		countdownLabel.TextTransparency = 0

		playStartSound()

		TweenService:Create(countdownLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{TextSize = 150}
		):Play()

		task.delay(0.8, function()
			TweenService:Create(countdownLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			task.delay(0.3, function()
				countdownFrame.Visible = false
				countdownLabel.TextTransparency = 0
				countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
		end)
	else
		countdownLabel.Text = tostring(count)
		countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		countdownLabel.TextSize = 80
		countdownLabel.TextTransparency = 0

		playCountdownSound()

		TweenService:Create(countdownLabel,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{TextSize = 200}
		):Play()

		task.delay(0.6, function()
			TweenService:Create(countdownLabel, TweenInfo.new(0.3),
				{TextSize = 150, TextTransparency = 0.5}
			):Play()
		end)
	end
end)

BattleReady.OnClientEvent:Connect(function()
	print("BattleReady - 操作可能")
	countdownFrame.Visible = false
end)

print("カウントダウンコントローラー起動完了")
