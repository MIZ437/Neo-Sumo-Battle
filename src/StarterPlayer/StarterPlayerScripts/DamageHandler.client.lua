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

-- サウンド取得
local gameSounds = Workspace:WaitForChild("GameSounds", 5)
local damageSound = gameSounds and gameSounds:FindFirstChild("DamageSound")
local hitSound = gameSounds and gameSounds:FindFirstChild("HitSound")

-- カメラシェイク
local function shakeCamera(intensity, duration)
    local cam = workspace.CurrentCamera
    if not cam then return end

    local originalCFrame = cam.CFrame

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

-- ダメージフラッシュエフェクト（強化版）
local function showDamageFlash(intensity)
    local playerGui = player:WaitForChild("PlayerGui")

    -- 赤フラッシュ
    local damageFlash = Instance.new("Frame")
    damageFlash.Name = "DamageFlash"
    damageFlash.Size = UDim2.new(1, 0, 1, 0)
    damageFlash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    damageFlash.BackgroundTransparency = 0.5
    damageFlash.BorderSizePixel = 0
    damageFlash.ZIndex = 100
    damageFlash.Parent = playerGui

    local tween = TweenService:Create(damageFlash, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        damageFlash:Destroy()
    end)

    -- ビネット効果（縁を暗く）
    local vignette = Instance.new("ImageLabel")
    vignette.Name = "DamageVignette"
    vignette.Size = UDim2.new(1, 0, 1, 0)
    vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://6842543624" -- ビネット画像
    vignette.ImageColor3 = Color3.fromRGB(255, 50, 50)
    vignette.ImageTransparency = 0.3
    vignette.ZIndex = 99
    vignette.Parent = playerGui

    local vignetteTween = TweenService:Create(vignette, TweenInfo.new(0.4), {
        ImageTransparency = 1
    })
    vignetteTween:Play()
    vignetteTween.Completed:Connect(function()
        vignette:Destroy()
    end)
end

-- ダメージ数値表示
local function showDamageNumber(position, damage, isPlayer)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
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
    damageLabel.TextColor3 = isPlayer and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 220, 50)
    damageLabel.TextSize = isPlayer and 32 or 28
    damageLabel.Font = Enum.Font.GothamBold
    damageLabel.TextStrokeTransparency = 0.3
    damageLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    damageLabel.Parent = billboard

    task.spawn(function()
        for i = 1, 20 do
            part.Position = part.Position + Vector3.new(0, 0.12, 0)
            damageLabel.TextTransparency = damageLabel.TextTransparency + 0.05
            damageLabel.TextStrokeTransparency = damageLabel.TextStrokeTransparency + 0.05
            task.wait(0.03)
        end
        part:Destroy()
    end)
end

-- 被ダメージエフェクト（パーティクル）
local function showDamageParticles(position)
    for i = 1, 8 do
        local particle = Instance.new("Part")
        particle.Shape = Enum.PartType.Ball
        particle.Size = Vector3.new(0.3, 0.3, 0.3)
        particle.Position = position
        particle.Anchored = false
        particle.CanCollide = false
        particle.Material = Enum.Material.Neon
        particle.Color = Color3.fromRGB(255, 100, 100)
        particle.Parent = workspace

        local direction = Vector3.new(
            math.random(-100, 100) / 100,
            math.random(50, 150) / 100,
            math.random(-100, 100) / 100
        )

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = direction * 20
        bv.Parent = particle

        task.spawn(function()
            task.wait(0.1)
            if bv.Parent then bv:Destroy() end
            for j = 1, 10 do
                particle.Transparency = particle.Transparency + 0.1
                particle.Size = particle.Size * 0.9
                task.wait(0.03)
            end
            particle:Destroy()
        end)
    end
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

            -- 被ダメージサウンド
            if damageSound then
                local clone = damageSound:Clone()
                clone.Parent = workspace
                clone:Play()
                task.delay(1, function() clone:Destroy() end)
            end

            -- 被ダメージをサーバーに通知
            if PlayerDamaged then
                PlayerDamaged:FireServer(damage)
            end

            -- エフェクト
            showDamageFlash(damage)
            showDamageNumber(rootPart.Position, damage, true)
            showDamageParticles(rootPart.Position)
            shakeCamera(0.3, 0.15)

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

            -- ヒットサウンド
            if hitSound then
                local clone = hitSound:Clone()
                clone.Parent = workspace
                clone:Play()
                task.delay(1, function() clone:Destroy() end)
            end
        end
    end
end)

-- 落下検出とGAME OVER表示
local fallingStartTime = nil
local gameOverShown = false
local gameOverGui = nil

local function createGameOverLabel()
    if gameOverGui and gameOverGui.Parent then return end

    gameOverGui = Instance.new("ScreenGui")
    gameOverGui.Name = "GameOverGui"
    gameOverGui.ResetOnSpawn = false
    gameOverGui.Parent = playerGui

    local gameOverLabel = Instance.new("TextLabel")
    gameOverLabel.Name = "GameOverLabel"
    gameOverLabel.Size = UDim2.new(1, 0, 0.3, 0)
    gameOverLabel.Position = UDim2.new(0, 0, 0.35, 0)
    gameOverLabel.BackgroundTransparency = 1
    gameOverLabel.Text = "GAME OVER"
    gameOverLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    gameOverLabel.TextSize = 72
    gameOverLabel.Font = Enum.Font.GothamBold
    gameOverLabel.TextStrokeTransparency = 0
    gameOverLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    gameOverLabel.Parent = gameOverGui
end

local function resetFallState()
    fallingStartTime = nil
    gameOverShown = false
    if gameOverGui and gameOverGui.Parent then
        gameOverGui:Destroy()
        gameOverGui = nil
    end
end

-- キャラクター追加時にリセット
player.CharacterAdded:Connect(resetFallState)

-- 落下検出
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if root.Position.Y < -5 then
        if not fallingStartTime then
            fallingStartTime = tick()
        elseif tick() - fallingStartTime >= 1 and not gameOverShown then
            createGameOverLabel()
            gameOverShown = true
        end
    else
        if fallingStartTime and not gameOverShown then
            fallingStartTime = nil
        end
    end
end)

print("DamageHandler READY (with enhanced effects + fall detection)")
