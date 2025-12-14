local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local battleUI = playerGui:WaitForChild("BattleUI")

local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateStats = Events:WaitForChild("UpdateStats")
local UpdateTimer = Events:WaitForChild("UpdateTimer")
local UpdateEnemyHP = Events:WaitForChild("UpdateEnemyHP")
local StartBattle = Events:WaitForChild("StartBattle")

local mainFrame = battleUI:WaitForChild("MainFrame")
local playerStatsFrame = mainFrame:WaitForChild("PlayerStatsFrame")
local hpFill = playerStatsFrame:WaitForChild("HPBar"):WaitForChild("Fill")
local stamFill = playerStatsFrame:WaitForChild("StaminaBar"):WaitForChild("Fill")

local skillFrame = mainFrame:WaitForChild("SkillFrame")
local spBar = skillFrame:WaitForChild("SPBar")
local spFill = spBar:WaitForChild("Fill")
local skillBtn = skillFrame:WaitForChild("SkillButton")

local enemyHPFrame = mainFrame:WaitForChild("EnemyHPFrame")
local enemyHPBar = enemyHPFrame:WaitForChild("HPBar")
local enemyName = enemyHPFrame:WaitForChild("NameLabel")

local timerLabel = mainFrame:WaitForChild("TimerFrame"):WaitForChild("TimerLabel")

local tw = TweenInfo.new(0.1)

UpdateStats.OnClientEvent:Connect(function(stats, state)
    local hpR = stats.HP / stats.MaxHP
    TweenService:Create(hpFill, tw, {Size = UDim2.new(hpR, 0, 1, 0)}):Play()
    hpFill.BackgroundColor3 = hpR < 0.3 and Color3.fromRGB(255,50,50) or hpR < 0.6 and Color3.fromRGB(255,200,50) or Color3.fromRGB(50,200,50)

    local stR = stats.Stamina / stats.MaxStamina
    TweenService:Create(stamFill, tw, {Size = UDim2.new(stR, 0, 1, 0)}):Play()
    stamFill.BackgroundColor3 = state.IsExhausted and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,200,50)

    local spR = stats.SP / stats.MaxSP
    TweenService:Create(spFill, tw, {Size = UDim2.new(spR, 0, 1, 0)}):Play()
    local canUse = stats.SP >= 50
    spFill.BackgroundColor3 = canUse and Color3.fromRGB(100,200,255) or Color3.fromRGB(80,120,180)
    skillBtn.BackgroundColor3 = canUse and Color3.fromRGB(100,150,255) or Color3.fromRGB(80,80,80)
end)

UpdateTimer.OnClientEvent:Connect(function(t)
    timerLabel.Text = string.format("%d:%02d", math.floor(t/60), math.floor(t%60))
    timerLabel.TextColor3 = t <= 30 and Color3.fromRGB(255,100,100) or Color3.fromRGB(255,255,255)
end)

UpdateEnemyHP.OnClientEvent:Connect(function(cur, max)
    TweenService:Create(enemyHPBar, tw, {Size = UDim2.new(cur/max, 0, 1, 0)}):Play()
end)

StartBattle.OnClientEvent:Connect(function(info)
    hpFill.Size = UDim2.new(1,0,1,0)
    stamFill.Size = UDim2.new(1,0,1,0)
    spFill.Size = UDim2.new(0,0,1,0)
    enemyHPBar.Size = UDim2.new(1,0,1,0)
    enemyName.Text = info.enemyName
    timerLabel.Text = "2:00"
end)

print("UIController READY")
