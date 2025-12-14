local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local menuUI = playerGui:WaitForChild("MenuUI")
local battleUI = playerGui:WaitForChild("BattleUI")

local Events = ReplicatedStorage:WaitForChild("Events")
local SelectStage = Events:WaitForChild("SelectStage")
local SelectSkill = Events:WaitForChild("SelectSkill")
local StartBattle = Events:WaitForChild("StartBattle")
local EndBattle = Events:WaitForChild("EndBattle")
local UpgradeStat = Events:WaitForChild("UpgradeStat")
local GetUpgradeInfo = Events:WaitForChild("GetUpgradeInfo")

local titleScreen = menuUI:WaitForChild("TitleScreen")
local homeScreen = menuUI:WaitForChild("HomeScreen")
local stageSelect = menuUI:WaitForChild("StageSelectScreen")
local skillSelect = menuUI:WaitForChild("SkillSelectScreen")
local resultScreen = menuUI:WaitForChild("ResultScreen")
local shopScreen = menuUI:WaitForChild("ShopScreen")

local playerData = {level = 1, coins = 100, maxStageCleared = 0, equippedSkill = 1, currentStage = 1}

local function showScreen(name)
    titleScreen.Visible = name == "Title"
    homeScreen.Visible = name == "Home"
    stageSelect.Visible = name == "StageSelect"
    skillSelect.Visible = name == "SkillSelect"
    resultScreen.Visible = name == "Result"
    shopScreen.Visible = name == "Shop"
    battleUI.MainFrame.Visible = name == "Battle"
end

local function updateHomeUI()
    local info = homeScreen:FindFirstChild("PlayerInfo")
    if info then
        info.LevelLabel.Text = "Lv. " .. playerData.level
        info.CoinLabel.Text = playerData.coins .. " コイン"
        local skills = {"Power Push", "Speed Boost", "Heal"}
        info.SkillLabel.Text = skills[playerData.equippedSkill]
    end
end

local function updateStageSelectUI()
    local grid = stageSelect:FindFirstChild("StageGrid")
    if grid then
        for i = 1, 10 do
            local btn = grid:FindFirstChild("Stage" .. i)
            if btn then
                local unlocked = i <= playerData.maxStageCleared + 1

                -- 背景色を設定
                if unlocked then
                    btn.BackgroundColor3 = (i == 10) and Color3.fromRGB(150,80,80) or Color3.fromRGB(80,150,80)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                end

                -- LockIconの表示/非表示を制御
                local lockIcon = btn:FindFirstChild("LockIcon")
                if lockIcon then
                    lockIcon.Visible = not unlocked
                end
            end
        end
    end
end

local function updateShopUI()
    local info = GetUpgradeInfo:InvokeServer()
    if not info then return end
    playerData.coins = info.coins
    shopScreen.CoinDisplay.Text = info.coins .. " コイン"
    local cards = shopScreen:FindFirstChild("CardsContainer")
    if cards then
        for stat, upg in pairs(info.upgrades) do
            local card = cards:FindFirstChild(stat .. "Card")
            if card then
                local lvl = card:FindFirstChild("LevelLabel")
                if lvl then lvl.Text = "Lv. " .. upg.level .. " / " .. upg.maxLevel end
                local cost = card:FindFirstChild("CostLabel")
                if cost then cost.Text = upg.isMaxed and "MAX" or upg.cost end
                local btn = card:FindFirstChild("UpgradeButton")
                if btn then
                    btn.Text = upg.isMaxed and "MAX" or info.coins < upg.cost and "コイン不足" or "強化する"
                    btn.BackgroundColor3 = upg.isMaxed and Color3.fromRGB(100,100,100) or info.coins < upg.cost and Color3.fromRGB(100,60,60) or Color3.fromRGB(80,150,80)
                end
            end
        end
    end
end

titleScreen:WaitForChild("StartButton").MouseButton1Click:Connect(function() showScreen("Home"); updateHomeUI() end)
homeScreen:WaitForChild("CPUBattleBtn").MouseButton1Click:Connect(function() showScreen("StageSelect"); updateStageSelectUI() end)
homeScreen:WaitForChild("SkillSelectBtn").MouseButton1Click:Connect(function() showScreen("SkillSelect") end)
homeScreen:WaitForChild("ShopBtn").MouseButton1Click:Connect(function() showScreen("Shop"); updateShopUI() end)

local grid = stageSelect:WaitForChild("StageGrid")
for i = 1, 10 do
    local btn = grid:FindFirstChild("Stage" .. i)
    if btn then
        btn.MouseButton1Click:Connect(function()
            if i <= playerData.maxStageCleared + 1 then
                playerData.currentStage = i
                SelectStage:FireServer(i)
            end
        end)
    end
end
stageSelect:WaitForChild("BackButton").MouseButton1Click:Connect(function() showScreen("Home") end)
skillSelect:WaitForChild("BackButton").MouseButton1Click:Connect(function() showScreen("Home") end)
shopScreen:WaitForChild("BackButton").MouseButton1Click:Connect(function() showScreen("Home"); updateHomeUI() end)

local cards = shopScreen:WaitForChild("CardsContainer")
for _, stat in ipairs({"HP", "Power", "Stability", "Speed"}) do
    local card = cards:FindFirstChild(stat .. "Card")
    if card then
        local btn = card:FindFirstChild("UpgradeButton")
        if btn then btn.MouseButton1Click:Connect(function() UpgradeStat:FireServer(stat) end) end
    end
end

UpgradeStat.OnClientEvent:Connect(function(result)
    playerData.coins = result.coins
    updateShopUI()
end)

local panel = resultScreen:WaitForChild("Panel")
panel:WaitForChild("NextButton").MouseButton1Click:Connect(function() showScreen("StageSelect"); updateStageSelectUI() end)
panel:WaitForChild("RetryButton").MouseButton1Click:Connect(function() SelectStage:FireServer(playerData.currentStage) end)
panel:WaitForChild("HomeButton").MouseButton1Click:Connect(function() showScreen("Home"); updateHomeUI() end)

StartBattle.OnClientEvent:Connect(function(info) showScreen("Battle") end)
EndBattle.OnClientEvent:Connect(function(result)
    showScreen("Result")
    local isWin = result.winner == "player"
    panel.ResultText.Text = isWin and "WIN!" or "LOSE..."
    panel.ResultText.TextColor3 = isWin and Color3.fromRGB(255,220,100) or Color3.fromRGB(200,80,80)
    local stats = panel:FindFirstChild("StatsFrame")
    if stats and result.stats then
        stats.SurvivalTime.Text = result.stats.survivalTime .. "秒"
        stats.DamageDealt.Text = result.stats.damageDealt
        stats.DamageTaken.Text = result.stats.damageTaken
    end
    local rewards = panel:FindFirstChild("Rewards")
    if rewards then
        rewards.ExpReward.Text = "+" .. result.rewards.exp
        rewards.CoinReward.Text = "+" .. result.rewards.coins
    end
    panel.NextButton.Visible = isWin
    panel.RetryButton.Visible = not isWin
    if isWin and result.stage > playerData.maxStageCleared then playerData.maxStageCleared = result.stage end
    playerData.coins = playerData.coins + result.rewards.coins
end)

showScreen("Title")
print("MenuController READY")
