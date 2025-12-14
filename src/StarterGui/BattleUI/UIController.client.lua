local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local battleUI = playerGui:WaitForChild("BattleUI")
local mainFrame = battleUI:WaitForChild("MainFrame")

-- ResultUIは別のScreenGui
local resultUI = playerGui:WaitForChild("ResultUI")
local resultFrame = resultUI:WaitForChild("ResultFrame")

local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateStats = Events:WaitForChild("UpdateStats")
local UpdateTimer = Events:WaitForChild("UpdateTimer")
local UpdateEnemyHP = Events:WaitForChild("UpdateEnemyHP")
local StartBattle = Events:WaitForChild("StartBattle")
local EndBattle = Events:WaitForChild("EndBattle")
local SelectStage = Events:WaitForChild("SelectStage")

local menuUI = playerGui:WaitForChild("MenuUI")

-- UI要素を安全に取得
local function safeFind(parent, name)
    return parent and parent:FindFirstChild(name)
end

local playerStatsFrame = safeFind(mainFrame, "PlayerStatsFrame")
local hpBarFrame = safeFind(playerStatsFrame, "HPBar")
local hpBar = safeFind(hpBarFrame, "Fill")
local staminaBarFrame = safeFind(playerStatsFrame, "StaminaBar")
local staminaBar = safeFind(staminaBarFrame, "Fill")

local enemyHPFrame = safeFind(mainFrame, "EnemyHPFrame")
local enemyHPBarFrame = safeFind(enemyHPFrame, "HPBar")
local enemyHPBar = safeFind(enemyHPBarFrame, "Fill") or enemyHPBarFrame
local enemyNameLabel = safeFind(enemyHPFrame, "EnemyName") or safeFind(enemyHPFrame, "NameLabel")

local timerFrame = safeFind(mainFrame, "TimerFrame")
local timerLabel = safeFind(timerFrame, "TimerLabel")

-- ResultFrame要素
local resultTitle = safeFind(resultFrame, "ResultTitle")
local stageLabel = safeFind(resultFrame, "StageLabel")
local rewardsFrame = safeFind(resultFrame, "RewardsFrame")
local expLabel = safeFind(rewardsFrame, "ExpLabel")
local coinsLabel = safeFind(rewardsFrame, "CoinsLabel")
local buttonsFrame = safeFind(resultFrame, "ButtonsFrame")
local primaryButton = safeFind(buttonsFrame, "PrimaryButton")
local shopButton = safeFind(buttonsFrame, "ShopButton")
local titleButton = safeFind(buttonsFrame, "TitleButton")

print("UIController: resultFrame =", resultFrame and "found" or "NOT FOUND")

local currentStage = 1
local tw = TweenInfo.new(0.1)

StartBattle.OnClientEvent:Connect(function(data)
    print("StartBattle received, stage:", data.stage)
    currentStage = data.stage or 1
    mainFrame.Visible = true
    resultFrame.Visible = false
    resultUI.Enabled = false
    if enemyNameLabel then enemyNameLabel.Text = data.enemyName or "Enemy" end
    if enemyHPBar then enemyHPBar.Size = UDim2.new(1, 0, 1, 0) end
    if hpBar then hpBar.Size = UDim2.new(1, 0, 1, 0) end
    if staminaBar then staminaBar.Size = UDim2.new(1, 0, 1, 0) end
    if timerLabel then timerLabel.Text = "2:00" end
end)

UpdateStats.OnClientEvent:Connect(function(stats, state)
    if not stats then return end
    local hpPercent = stats.HP / stats.MaxHP
    if hpBar then
        TweenService:Create(hpBar, tw, {Size = UDim2.new(hpPercent, 0, 1, 0)}):Play()
        hpBar.BackgroundColor3 = hpPercent < 0.3 and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,200,50)
    end
    if staminaBar then
        local stR = stats.Stamina / stats.MaxStamina
        TweenService:Create(staminaBar, tw, {Size = UDim2.new(stR, 0, 1, 0)}):Play()
    end
end)

UpdateTimer.OnClientEvent:Connect(function(time)
    if timerLabel then
        timerLabel.Text = string.format("%d:%02d", math.floor(time/60), math.floor(time%60))
        timerLabel.TextColor3 = time <= 30 and Color3.fromRGB(255,100,100) or Color3.fromRGB(255,255,255)
    end
end)

UpdateEnemyHP.OnClientEvent:Connect(function(hp, maxHP)
    if enemyHPBar then
        local percent = hp / maxHP
        TweenService:Create(enemyHPBar, tw, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    end
end)

EndBattle.OnClientEvent:Connect(function(data)
    print("=== EndBattle received! ===")
    print("Winner:", data.winner, "Reason:", data.reason)

    local isWin = data.winner == "player"

    if resultTitle then
        if isWin then
            resultTitle.Text = "VICTORY!"
            resultTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
        else
            resultTitle.Text = "DEFEAT..."
            resultTitle.TextColor3 = Color3.fromRGB(200, 50, 50)
        end
    end

    if stageLabel then
        if isWin then
            stageLabel.Text = "Stage " .. data.stage .. " クリア!"
        else
            local reasonText = ""
            if data.reason == "Fall" then reasonText = " (落下)"
            elseif data.reason == "KO" then reasonText = " (KO)"
            elseif data.reason == "TimeUp" then reasonText = " (時間切れ)"
            end
            stageLabel.Text = "Stage " .. data.stage .. reasonText
        end
    end

    if primaryButton then
        if isWin then
            primaryButton.Text = "次に進む"
            primaryButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        else
            primaryButton.Text = "リトライ"
            primaryButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
        end
    end

    local rewards = data.rewards or {exp = 0, coins = 0}
    if expLabel then expLabel.Text = "EXP: +" .. rewards.exp end
    if coinsLabel then coinsLabel.Text = "コイン: +" .. rewards.coins end

    -- GAME OVER GUIがあれば削除
    local gameOverGui = playerGui:FindFirstChild("GameOverGui")
    if gameOverGui then gameOverGui:Destroy() end

    -- 結果画面表示
    resultUI.Enabled = true
    resultFrame.Visible = true
    resultFrame.Position = UDim2.new(0.25, 0, 0.15, 0)

    print("Result screen shown! resultUI.Enabled:", resultUI.Enabled)
end)

if primaryButton then
    primaryButton.MouseButton1Click:Connect(function()
        print("Primary button clicked:", primaryButton.Text)
        resultFrame.Visible = false
        resultUI.Enabled = false
        mainFrame.Visible = false
        if primaryButton.Text == "次に進む" then
            SelectStage:FireServer(math.min(currentStage + 1, 10))
        else
            SelectStage:FireServer(currentStage)
        end
    end)
end

if shopButton then
    shopButton.MouseButton1Click:Connect(function()
        resultFrame.Visible = false
        resultUI.Enabled = false
        mainFrame.Visible = false
        menuUI.Enabled = true
    end)
end

if titleButton then
    titleButton.MouseButton1Click:Connect(function()
        resultFrame.Visible = false
        resultUI.Enabled = false
        mainFrame.Visible = false
        menuUI.Enabled = true
    end)
end

print("UIController READY (with separate ResultUI)")
