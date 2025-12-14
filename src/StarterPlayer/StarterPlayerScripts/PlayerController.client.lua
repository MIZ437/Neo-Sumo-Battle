local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local PlayerAction = Events:WaitForChild("PlayerAction")
local DamageDealt = Events:WaitForChild("DamageDealt")
local BattleReady = Events:WaitForChild("BattleReady")
local Countdown = Events:WaitForChild("Countdown")
local StartBattle = Events:WaitForChild("StartBattle")

local canAct = false
local isGuarding = false
local lastPushTime = 0
local cameraRot = 0
local cameraPitch = 0
local keysDown = {}

StartBattle.OnClientEvent:Connect(function() canAct = false end)
Countdown.OnClientEvent:Connect(function() canAct = false end)
BattleReady.OnClientEvent:Connect(function() canAct = true; print("CAN ACT!") end)

local function attack()
    if not canAct or isGuarding or tick() - lastPushTime < 0.4 then return end
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
                break
            end
        end
    end
    PlayerAction:FireServer("Push", root.Position)
end

local function guardStart()
    if not canAct then return end
    isGuarding = true
    PlayerAction:FireServer("Guard", true)
end

local function guardEnd()
    isGuarding = false
    PlayerAction:FireServer("Guard", false)
end

local function dodge(dir)
    if not canAct then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local cam = workspace.CurrentCamera
    local right = cam.CFrame.RightVector
    right = Vector3.new(right.X, 0, right.Z).Unit
    local dodgeDir = dir == "Left" and -right or right
    PlayerAction:FireServer("Dodge", dodgeDir)
end

local function skill()
    if not canAct then return end
    PlayerAction:FireServer("Skill")
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    keysDown[input.KeyCode] = true
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

print("PlayerController READY")
