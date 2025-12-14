local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = ReplicatedStorage:WaitForChild("Config")

local PlayerData = require(Modules:WaitForChild("PlayerData"))
local EnemyFactory = require(Modules:WaitForChild("EnemyFactory"))
local EnemyAI = require(Modules:WaitForChild("EnemyAI"))
local GameConfig = require(Config:WaitForChild("GameConfig"))

local StartBattle = Events:WaitForChild("StartBattle")
local EndBattle = Events:WaitForChild("EndBattle")
local SelectStage = Events:WaitForChild("SelectStage")
local DamageDealt = Events:WaitForChild("DamageDealt")
local UpdateStats = Events:WaitForChild("UpdateStats")
local UpdateTimer = Events:WaitForChild("UpdateTimer")
local UpdateEnemyHP = Events:WaitForChild("UpdateEnemyHP")
local Countdown = Events:WaitForChild("Countdown")
local BattleReady = Events:WaitForChild("BattleReady")

-- チュートリアル用イベント
local StartTutorial = Events:WaitForChild("StartTutorial")
local TutorialComplete = Events:WaitForChild("TutorialComplete")
local SkipTutorial = Events:WaitForChild("SkipTutorial")

local Arena = Workspace:WaitForChild("Arena")
local EnemiesFolder = Workspace:WaitForChild("Enemies")

local activeBattles = {}
local pendingTutorials = {} -- チュートリアル待ちのプレイヤー

local function clearEnemies()
    for _, e in ipairs(EnemiesFolder:GetChildren()) do e:Destroy() end
end

local function endBattle(player, winner, reason)
    local battle = activeBattles[player]
    if not battle then return end
    print("END: " .. winner .. " " .. reason)
    battle.active = false
    if battle.connection then battle.connection:Disconnect() end
    if battle.enemyAI then battle.enemyAI.Active = false end

    local data = PlayerData.Get(player)
    local rewards = {exp = 0, coins = 0, crystals = 0}

    -- 獲得クリスタル数を取得
    local crystalsEarned = 0
    if data and data.Crystals then
        crystalsEarned = data.Crystals
        data.Crystals = 0 -- リセット
    end
    rewards.crystals = crystalsEarned

    if winner == "player" then
        rewards.exp = battle.stage * 20
        rewards.coins = battle.stage * 15
        -- 勝利ボーナスクリスタル
        rewards.crystals = rewards.crystals + math.floor(battle.stage / 2)
        if data and battle.stage > data.MaxStageCleared then
            data.MaxStageCleared = battle.stage
        end
    else
        rewards.exp = battle.stage * 5
        rewards.coins = battle.stage * 3
    end
    if data then
        data.State.InBattle = false
        data:AddExp(rewards.exp)
        data.Coins = data.Coins + rewards.coins
        data.TotalCrystals = (data.TotalCrystals or 0) + rewards.crystals
    end

    EndBattle:FireClient(player, {
        winner = winner, reason = reason, rewards = rewards, stage = battle.stage,
        stats = {survivalTime = math.floor(battle.survivalTime), damageDealt = math.floor(battle.damageDealt), damageTaken = math.floor(battle.damageTaken)}
    })
    clearEnemies()
    activeBattles[player] = nil
end

local function startBattle(player, stage)
    print("START BATTLE: " .. player.Name .. " Stage " .. stage)
    if activeBattles[player] then endBattle(player, "cancel", "Restart") end

    local data = PlayerData.Get(player)
    if not data then data = PlayerData.new(player) end
    data:ResetBattleState()
    data.State.InBattle = true
    data.Stats.SP = 0

    -- キャラクターをリスポーン位置に移動
    local char = player.Character
    if not char then
        player:LoadCharacter()
        char = player.CharacterAdded:Wait()
    end

    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)

    if root then
        local spawn = Arena:FindFirstChild("PlayerSpawn")
        local spawnPosition = spawn and spawn.Position or Vector3.new(-10, 10, 0)
        -- 確実にスポーン位置に配置
        root.CFrame = CFrame.new(spawnPosition + Vector3.new(0, 3, 0))
        -- 速度をリセット
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        print("Player spawned at:", spawnPosition)
    end

    if hum then
        hum.Health = hum.MaxHealth
    end

    clearEnemies()
    local spawnPos = Arena:FindFirstChild("EnemySpawn") and Arena.EnemySpawn.Position or Vector3.new(15,10,0)
    local enemy = stage == 10 and EnemyFactory.CreateBoss("GrassGolem", spawnPos) or EnemyFactory.CreateStageEnemy(stage, spawnPos)
    enemy.Parent = EnemiesFolder

    local ai = EnemyAI.new(enemy)
    ai.Active = false

    local battle = {
        player = player, enemy = enemy, enemyAI = ai, stage = stage,
        startTime = nil, timeRemaining = 120, active = false, connection = nil,
        damageDealt = 0, damageTaken = 0, survivalTime = 0
    }
    activeBattles[player] = battle

    StartBattle:FireClient(player, {stage = stage, enemyName = enemy.Name, enemyHP = enemy.EnemyData.MaxHP.Value})
    UpdateStats:FireClient(player, data.Stats, data.State)
    UpdateTimer:FireClient(player, 120)

    task.spawn(function()
        for i = 3, 1, -1 do Countdown:FireClient(player, i); task.wait(1) end
        Countdown:FireClient(player, 0); task.wait(0.5)
        if not activeBattles[player] then return end

        battle.active = true
        battle.startTime = tick()
        battle.enemyAI.Active = true
        print("AI ACTIVE!")
        BattleReady:FireClient(player)

        battle.connection = RunService.Heartbeat:Connect(function(dt)
            if not battle.active then return end
            local d = PlayerData.Get(player)
            if not d then return end

            d.Stats.SP = math.min(100, d.Stats.SP + 5 * dt)
            d.Stats.Stamina = math.min(100, d.Stats.Stamina + 10 * dt)

            if battle.enemyAI and battle.enemyAI.Active then
                battle.enemyAI:Update(dt)
            end

            battle.survivalTime = tick() - battle.startTime
            battle.timeRemaining = 120 - battle.survivalTime

            UpdateTimer:FireClient(player, math.max(0, battle.timeRemaining))
            UpdateStats:FireClient(player, d.Stats, d.State)

            if battle.enemy and battle.enemy:FindFirstChild("EnemyData") then
                local ed = battle.enemy.EnemyData
                UpdateEnemyHP:FireClient(player, ed.HP.Value, ed.MaxHP.Value)
            end

            if battle.timeRemaining <= 0 then
                endBattle(player, "enemy", "TimeUp")
                return
            end

            if player.Character then
                local r = player.Character:FindFirstChild("HumanoidRootPart")
                if r and r.Position.Y < -20 then
                    endBattle(player, "enemy", "Fall")
                    return
                end
            end

            if battle.enemy then
                local er = battle.enemy:FindFirstChild("HumanoidRootPart")
                if er and er.Position.Y < -20 then
                    print("ENEMY FELL!")
                    endBattle(player, "player", "RingOut")
                    return
                end
            end
        end)
    end)
end

-- チュートリアル完了時の処理
TutorialComplete.OnServerEvent:Connect(function(player)
    local data = PlayerData.Get(player)
    if data then
        data.TutorialCompleted = true
    end

    local pendingStage = pendingTutorials[player]
    if pendingStage then
        pendingTutorials[player] = nil
        startBattle(player, pendingStage)
    end
end)

-- チュートリアルスキップ時の処理
SkipTutorial.OnServerEvent:Connect(function(player)
    local data = PlayerData.Get(player)
    if data then
        data.TutorialCompleted = true
    end

    local pendingStage = pendingTutorials[player]
    if pendingStage then
        pendingTutorials[player] = nil
        startBattle(player, pendingStage)
    end
end)

DamageDealt.OnServerEvent:Connect(function(player, target, damage, knockback)
    local battle = activeBattles[player]
    if not battle or not battle.active then return end
    if target == battle.enemy and battle.enemyAI then
        local dead = battle.enemyAI:TakeDamage(damage, knockback)
        battle.damageDealt = battle.damageDealt + damage
        if dead then endBattle(player, "player", "KO") end
    end
end)

SelectStage.OnServerEvent:Connect(function(player, stage)
    if stage < 1 or stage > 10 then return end
    local data = PlayerData.Get(player)
    if not data then data = PlayerData.new(player) end
    if stage > data.MaxStageCleared + 1 then return end

    -- ステージ1でチュートリアル未完了の場合
    if stage == 1 and not data.TutorialCompleted then
        pendingTutorials[player] = stage
        StartTutorial:FireClient(player)
        return
    end

    startBattle(player, stage)
end)

Players.PlayerAdded:Connect(function(player)
    PlayerData.new(player)
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            local b = activeBattles[player]
            if b and b.active then endBattle(player, "enemy", "KO") end
        end)
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if not PlayerData.Get(p) then PlayerData.new(p) end
end

print("BattleManager READY (with Tutorial)")
