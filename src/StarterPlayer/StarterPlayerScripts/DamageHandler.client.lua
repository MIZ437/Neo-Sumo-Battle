-- プレイヤーダメージ処理（エフェクト強化版）
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events")
local DamageDealt = Events:WaitForChild("DamageDealt")
local PlayerDamaged = Events:WaitForChild("PlayerDamaged", 5)
local StartBattle = Events:WaitForChild("StartBattle")
local Countdown = Events:WaitForChild("Countdown")

local gameSounds = Workspace:WaitForChild("GameSounds", 5)
local damageSound = gameSounds and gameSounds:FindFirstChild("DamageSound")
local hitSound = gameSounds and gameSounds:FindFirstChild("HitSound")

-- カメラシェイク
local function shakeCamera(intensity, duration)
    local cam = workspace.CurrentCamera
    if not cam then return end
    task.spawn(function()
        local elapsed = 0
        while elapsed < duration do
            local shakeX = (math.random() - 0.5) * intensity
            local shakeY = (math.random() - 0.5) * intensity
            cam.CFrame = cam.CFrame * CFrame.new(shakeX, shakeY, 0)
            elapsed = elapsed + 0.02
            task.wait(0.02)
        end
    end)
end

-- ダメージフラッシュ
local function showDamageFlash()
    local damageFlash = Instance.new("Frame")
    damageFlash.Name = "DamageFlash"
    damageFlash.Size = UDim2.new(1, 0, 1, 0)
    damageFlash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    damageFlash.BackgroundTransparency = 0.5
    damageFlash.BorderSizePixel = 0
    damageFlash.ZIndex = 100
    damageFlash.Parent = playerGui

    local tween = TweenService:Create(damageFlash, TweenInfo.new(0.3), {BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Connect(function() damageFlash:Destroy() end)
end

-- ダメージ数値表示
local function showDamageNumber(position, damage, isPlayer)
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Position = position + Vector3.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.Parent = part

    local damageLabel = Instance.new("TextLabel")
    damageLabel.Size = UDim2.new(1, 0, 1, 0)
    damageLabel.BackgroundTransparency = 1
    damageLabel.Text = "-" .. math.floor(damage)
    damageLabel.TextColor3 = isPlayer and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 220, 50)
    damageLabel.TextSize = isPlayer and 32 or 28
    damageLabel.Font = Enum.Font.GothamBold
    damageLabel.TextStrokeTransparency = 0.3
    damageLabel.Parent = billboard

    task.spawn(function()
        for i = 1, 20 do
            part.Position = part.Position + Vector3.new(0, 0.12, 0)
            damageLabel.TextTransparency = damageLabel.TextTransparency + 0.05
            task.wait(0.03)
        end
        part:Destroy()
    end)
end

-- ダメージ受信
DamageDealt.OnClientEvent:Connect(function(target, damage, knockback)
    local character = player.Character
    if not character then return end

    if target == character then
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            humanoid:TakeDamage(damage)
            if damageSound then
                local clone = damageSound:Clone()
                clone.Parent = workspace
                clone:Play()
                task.delay(1, function() clone:Destroy() end)
            end
            if PlayerDamaged then PlayerDamaged:FireServer(damage) end
            showDamageFlash()
            showDamageNumber(rootPart.Position, damage, true)
            shakeCamera(0.3, 0.15)
            if knockback then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = knockback
                bv.Parent = rootPart
                task.delay(0.2, function() if bv.Parent then bv:Destroy() end end)
            end
        end
    end

    if target and target:FindFirstChild("EnemyData") then
        local enemyRoot = target:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            showDamageNumber(enemyRoot.Position, damage, false)
            if hitSound then
                local clone = hitSound:Clone()
                clone.Parent = workspace
                clone:Play()
                task.delay(1, function() clone:Destroy() end)
            end
        end
    end
end)

-- 落下検出とおどろおどろしいGAME OVER表示
local fallingStartTime = nil
local gameOverShown = false
local gameOverGui = nil

local function createDramaticGameOver()
    if gameOverGui and gameOverGui.Parent then return end

    gameOverGui = Instance.new("ScreenGui")
    gameOverGui.Name = "GameOverGui"
    gameOverGui.ResetOnSpawn = false
    gameOverGui.DisplayOrder = 100
    gameOverGui.Parent = playerGui

    -- 暗転背景
    local darkBg = Instance.new("Frame")
    darkBg.Name = "DarkBackground"
    darkBg.Size = UDim2.new(1, 0, 1, 0)
    darkBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    darkBg.BackgroundTransparency = 1
    darkBg.BorderSizePixel = 0
    darkBg.Parent = gameOverGui

    -- GAME OVERテキスト
    local gameOverLabel = Instance.new("TextLabel")
    gameOverLabel.Name = "GameOverLabel"
    gameOverLabel.Size = UDim2.new(1, 0, 0.4, 0)
    gameOverLabel.Position = UDim2.new(0, 0, 0.3, 0)
    gameOverLabel.BackgroundTransparency = 1
    gameOverLabel.Text = "GAME OVER"
    gameOverLabel.TextColor3 = Color3.fromRGB(150, 0, 0)
    gameOverLabel.TextSize = 50
    gameOverLabel.Font = Enum.Font.GothamBlack
    gameOverLabel.TextStrokeTransparency = 0
    gameOverLabel.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)
    gameOverLabel.TextTransparency = 1
    gameOverLabel.Parent = gameOverGui

    -- 不気味なサウンド再生
    local gameOverSound = Instance.new("Sound")
    gameOverSound.SoundId = "rbxassetid://1837774679"
    gameOverSound.Volume = 1.5
    gameOverSound.Parent = gameOverGui
    gameOverSound:Play()

    -- 暗転アニメーション
    TweenService:Create(darkBg, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.7
    }):Play()

    -- テキストフェードイン + 拡大
    task.delay(0.3, function()
        TweenService:Create(gameOverLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            TextSize = 120
        }):Play()
    end)

    -- テキスト揺れ効果
    task.spawn(function()
        task.wait(1.2)
        while gameOverGui and gameOverGui.Parent do
            local shakeX = math.random(-3, 3)
            local shakeY = math.random(-2, 2)
            gameOverLabel.Position = UDim2.new(0, shakeX, 0.3, shakeY)
            local intensity = math.random(100, 180)
            gameOverLabel.TextColor3 = Color3.fromRGB(intensity, 0, 0)
            task.wait(0.05)
        end
    end)

    -- 赤いビネット効果
    local vignette = Instance.new("ImageLabel")
    vignette.Name = "RedVignette"
    vignette.Size = UDim2.new(1, 0, 1, 0)
    vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://6842543624"
    vignette.ImageColor3 = Color3.fromRGB(100, 0, 0)
    vignette.ImageTransparency = 0.5
    vignette.ZIndex = 2
    vignette.Parent = gameOverGui
end

local function resetFallState()
    fallingStartTime = nil
    gameOverShown = false
    if gameOverGui and gameOverGui.Parent then
        gameOverGui:Destroy()
        gameOverGui = nil
    end
end

player.CharacterAdded:Connect(resetFallState)

-- バトル開始時にGAME OVERをリセット
StartBattle.OnClientEvent:Connect(function()
    resetFallState()
end)

Countdown.OnClientEvent:Connect(function()
    resetFallState()
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if root.Position.Y < -5 then
        if not fallingStartTime then
            fallingStartTime = tick()
        elseif tick() - fallingStartTime >= 1 and not gameOverShown then
            createDramaticGameOver()
            gameOverShown = true
        end
    else
        if fallingStartTime and not gameOverShown then
            fallingStartTime = nil
        end
    end
end)

print("DamageHandler READY (with dramatic GAME OVER)")
