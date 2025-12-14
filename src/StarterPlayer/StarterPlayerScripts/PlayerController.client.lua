local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events")
local PlayerAction = Events:WaitForChild("PlayerAction")
local DamageDealt = Events:WaitForChild("DamageDealt")
local BattleReady = Events:WaitForChild("BattleReady")
local Countdown = Events:WaitForChild("Countdown")
local StartBattle = Events:WaitForChild("StartBattle")
local StartTutorial = Events:WaitForChild("StartTutorial")
local EndBattle = Events:WaitForChild("EndBattle")

-- UI参照
local battleUI = playerGui:WaitForChild("BattleUI")
local mainFrame = battleUI:WaitForChild("MainFrame")
local controlsOverlay = mainFrame:FindFirstChild("ControlsOverlay")
local pauseFrame = mainFrame:FindFirstChild("PauseFrame")
local menuUI = playerGui:WaitForChild("MenuUI")

local gameSounds = Workspace:WaitForChild("GameSounds", 5)
local hitSound = gameSounds and gameSounds:FindFirstChild("HitSound")
local skillSound = gameSounds and gameSounds:FindFirstChild("SkillSound")

local canAct = false
local tutorialMode = false
local isGuarding = false
local isPaused = false
local inBattle = false
local lastPushTime = 0
local cameraRot = 0
local cameraPitch = 0
local keysDown = {}
local originalWalkSpeed = 16
local movementDisabled = false
local guardEffect = nil
local guardConnection = nil

local function canPerformAction()
    if isPaused then return false end
    return canAct or tutorialMode
end

-- 一時停止機能
local function togglePause()
    if not inBattle then return end
    isPaused = not isPaused

    if pauseFrame then
        pauseFrame.Visible = isPaused
    end

    -- ゲームを一時停止/再開
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if isPaused then
                originalWalkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
                humanoid.WalkSpeed = 0
            else
                humanoid.WalkSpeed = originalWalkSpeed
            end
        end
    end
end

local function resumeGame()
    if isPaused then
        togglePause()
    end
end

local function goToTitle()
    isPaused = false
    inBattle = false
    canAct = false

    if pauseFrame then
        pauseFrame.Visible = false
    end

    mainFrame.Visible = false
    menuUI.Enabled = true

    -- タイトル画面に戻る
    local titleScreen = menuUI:FindFirstChild("TitleScreen")
    local homeScreen = menuUI:FindFirstChild("HomeScreen")
    local stageSelect = menuUI:FindFirstChild("StageSelectScreen")
    local skillSelect = menuUI:FindFirstChild("SkillSelectScreen")
    local resultScreen = menuUI:FindFirstChild("ResultScreen")
    local shopScreen = menuUI:FindFirstChild("ShopScreen")

    if titleScreen then titleScreen.Visible = true end
    if homeScreen then homeScreen.Visible = false end
    if stageSelect then stageSelect.Visible = false end
    if skillSelect then skillSelect.Visible = false end
    if resultScreen then resultScreen.Visible = false end
    if shopScreen then shopScreen.Visible = false end
end

-- 操作説明の表示切り替え
local function toggleControls()
    if controlsOverlay then
        controlsOverlay.Visible = not controlsOverlay.Visible
    end
end

local function disableMovement()
    movementDisabled = true
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
            humanoid.WalkSpeed = 0
        end
    end
end

local function enableMovement()
    movementDisabled = false
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        if movementDisabled then
            originalWalkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
            humanoid.WalkSpeed = 0
        end
    end
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

StartBattle.OnClientEvent:Connect(function()
    canAct = false
    tutorialMode = false
    inBattle = true
    isPaused = false
    if pauseFrame then pauseFrame.Visible = false end
    disableMovement()
end)

EndBattle.OnClientEvent:Connect(function()
    inBattle = false
    isPaused = false
    if pauseFrame then pauseFrame.Visible = false end
end)

Countdown.OnClientEvent:Connect(function()
    canAct = false
    disableMovement()
end)

BattleReady.OnClientEvent:Connect(function()
    canAct = true
    tutorialMode = false
    enableMovement()
end)

StartTutorial.OnClientEvent:Connect(function()
    tutorialMode = true
    canAct = false
    enableMovement()
    print("Tutorial mode enabled - actions allowed")
end)

local function playHitEffect(position)
    if hitSound then
        local clone = hitSound:Clone()
        clone.Parent = Workspace
        clone:Play()
        task.delay(1, function() clone:Destroy() end)
    end

    local effect = Instance.new("Part")
    effect.Shape = Enum.PartType.Ball
    effect.Size = Vector3.new(1, 1, 1)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Material = Enum.Material.Neon
    effect.Color = Color3.fromRGB(255, 200, 50)
    effect.Transparency = 0.3
    effect.Parent = Workspace

    task.spawn(function()
        for i = 1, 8 do
            effect.Size = effect.Size + Vector3.new(0.8, 0.8, 0.8)
            effect.Transparency = effect.Transparency + 0.08
            task.wait(0.02)
        end
        effect:Destroy()
    end)

    for j = 1, 6 do
        local line = Instance.new("Part")
        line.Size = Vector3.new(0.2, 0.2, 2)
        line.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(60 * j), 0) * CFrame.new(0, 0, -1)
        line.Anchored = true
        line.CanCollide = false
        line.Material = Enum.Material.Neon
        line.Color = Color3.fromRGB(255, 255, 200)
        line.Transparency = 0.3
        line.Parent = Workspace

        task.spawn(function()
            for i = 1, 6 do
                line.Size = line.Size + Vector3.new(0, 0, 0.5)
                line.CFrame = line.CFrame * CFrame.new(0, 0, -0.25)
                line.Transparency = line.Transparency + 0.1
                task.wait(0.02)
            end
            line:Destroy()
        end)
    end
end

local function playSkillEffect(position)
    if skillSound then
        local clone = skillSound:Clone()
        clone.Parent = Workspace
        clone:Play()
        task.delay(2, function() clone:Destroy() end)
    end

    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.5, 2, 2)
    ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(100, 200, 255)
    ring.Transparency = 0.3
    ring.Parent = Workspace

    task.spawn(function()
        for i = 1, 15 do
            ring.Size = ring.Size + Vector3.new(0, 2, 2)
            ring.Transparency = ring.Transparency + 0.05
            task.wait(0.02)
        end
        ring:Destroy()
    end)
end

local function attack()
    if not canPerformAction() or isGuarding or tick() - lastPushTime < 0.4 then return end
    lastPushTime = tick()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, e in ipairs(enemies:GetChildren()) do
            local er = e:FindFirstChild("HumanoidRootPart")
            if er and (root.Position - er.Position).Magnitude <= 6 then
                local dir = (er.Position - root.Position).Unit
                dir = Vector3.new(dir.X, 0.3, dir.Z).Unit
                DamageDealt:FireServer(e, 10, dir * 30)
                local hitPos = (root.Position + er.Position) / 2
                playHitEffect(hitPos)
                break
            end
        end
    end

    -- チュートリアル中でもエフェクトを表示
    if tutorialMode then
        playHitEffect(root.Position + root.CFrame.LookVector * 2)
    end

    PlayerAction:FireServer("Push", root.Position)
end

local function guardStart()
    if not canPerformAction() then return end
    isGuarding = true

    local char = player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            guardEffect = Instance.new("Part")
            guardEffect.Name = "GuardShield"
            guardEffect.Shape = Enum.PartType.Ball
            guardEffect.Size = Vector3.new(6, 6, 6)
            guardEffect.Position = root.Position
            guardEffect.Anchored = true
            guardEffect.CanCollide = false
            guardEffect.Material = Enum.Material.ForceField
            guardEffect.Color = Color3.fromRGB(100, 150, 255)
            guardEffect.Transparency = 0.7
            guardEffect.Parent = Workspace

            guardConnection = RunService.Heartbeat:Connect(function()
                if guardEffect and guardEffect.Parent and root and root.Parent then
                    guardEffect.Position = root.Position
                else
                    if guardConnection then
                        guardConnection:Disconnect()
                        guardConnection = nil
                    end
                end
            end)
        end
    end

    PlayerAction:FireServer("Guard", true)
end

local function guardEnd()
    isGuarding = false

    if guardConnection then
        guardConnection:Disconnect()
        guardConnection = nil
    end
    if guardEffect and guardEffect.Parent then
        guardEffect:Destroy()
        guardEffect = nil
    end

    PlayerAction:FireServer("Guard", false)
end

local function dodge(dir)
    if not canPerformAction() then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    local cam = workspace.CurrentCamera
    local right = cam.CFrame.RightVector
    right = Vector3.new(right.X, 0, right.Z).Unit
    local dodgeDir = dir == "Left" and -right or right

    local hopForce = dodgeDir * 40 + Vector3.new(0, 15, 0)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(50000, 50000, 50000)
    bv.Velocity = hopForce
    bv.Parent = root

    task.spawn(function()
        for i = 1, 3 do
            local ghost = Instance.new("Part")
            ghost.Size = Vector3.new(2, 4, 1)
            ghost.CFrame = root.CFrame
            ghost.Anchored = true
            ghost.CanCollide = false
            ghost.Material = Enum.Material.Neon
            ghost.Color = Color3.fromRGB(100, 200, 255)
            ghost.Transparency = 0.5
            ghost.Parent = Workspace

            task.spawn(function()
                for j = 1, 6 do
                    ghost.Transparency = ghost.Transparency + 0.08
                    task.wait(0.03)
                end
                ghost:Destroy()
            end)
            task.wait(0.05)
        end
    end)

    task.delay(0.15, function()
        if bv and bv.Parent then
            bv:Destroy()
        end
    end)

    PlayerAction:FireServer("Dodge", dodgeDir)
end

local function skill()
    if not canPerformAction() then return end
    local char = player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            playSkillEffect(root.Position)
        end
    end
    PlayerAction:FireServer("Skill")
end

UserInputService.InputBegan:Connect(function(input, gp)
    -- Pキーは常に処理（一時停止用）
    if input.KeyCode == Enum.KeyCode.P then
        togglePause()
        return
    end

    -- Hキーは常に処理（操作説明表示用）
    if input.KeyCode == Enum.KeyCode.H then
        toggleControls()
        return
    end

    if gp then return end
    keysDown[input.KeyCode] = true

    -- 一時停止中はアクション不可
    if isPaused then return end

    if input.KeyCode == Enum.KeyCode.F then attack()
    elseif input.KeyCode == Enum.KeyCode.LeftShift then guardStart()
    elseif input.KeyCode == Enum.KeyCode.Q then dodge("Left")
    elseif input.KeyCode == Enum.KeyCode.E then dodge("Right")
    elseif input.KeyCode == Enum.KeyCode.R then skill()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    keysDown[input.KeyCode] = false
    if input.KeyCode == Enum.KeyCode.LeftShift then guardEnd() end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if keysDown[Enum.KeyCode.Left] then cameraRot = cameraRot + 2 end
    if keysDown[Enum.KeyCode.Right] then cameraRot = cameraRot - 2 end
    if keysDown[Enum.KeyCode.Up] then cameraPitch = math.clamp(cameraPitch + 1, -30, 60) end
    if keysDown[Enum.KeyCode.Down] then cameraPitch = math.clamp(cameraPitch - 1, -30, 60) end

    local dist = 15
    local rotRad = math.rad(cameraRot)
    local pitchRad = math.rad(cameraPitch)
    local offset = Vector3.new(math.sin(rotRad)*dist*math.cos(pitchRad), 8 + math.sin(pitchRad)*dist*0.5, math.cos(rotRad)*dist*math.cos(pitchRad))
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(root.Position + offset, root.Position + Vector3.new(0,2,0))
end)

-- ポーズメニューのボタン接続
if pauseFrame then
    local resumeBtn = pauseFrame:FindFirstChild("ResumeButton")
    local titleBtn = pauseFrame:FindFirstChild("TitleButton")

    if resumeBtn then
        resumeBtn.MouseButton1Click:Connect(resumeGame)
    end

    if titleBtn then
        titleBtn.MouseButton1Click:Connect(goToTitle)
    end
end

print("PlayerController READY (tutorial mode + effects + pause)")
