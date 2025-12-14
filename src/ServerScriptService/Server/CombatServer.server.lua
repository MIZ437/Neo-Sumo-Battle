local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = ReplicatedStorage:WaitForChild("Config")

local PlayerData = require(Modules:WaitForChild("PlayerData"))
local GameConfig = require(Config:WaitForChild("GameConfig"))

local PlayerAction = Events:WaitForChild("PlayerAction")
local UpdateStats = Events:WaitForChild("UpdateStats")

PlayerAction.OnServerEvent:Connect(function(player, action, ...)
    local data = PlayerData.Get(player)
    if not data or not data.State.InBattle then return end

    if action == "Push" then
        data:UseStamina(5)
    elseif action == "Guard" then
        local isGuarding = ...
        data.State.IsGuarding = isGuarding
    elseif action == "Dodge" then
        if not data:UseStamina(15) then return end
        local dir = ...
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(50000, 0, 50000)
                bv.Velocity = dir * 40
                bv.Parent = root
                data.State.IsInvincible = true
                task.delay(0.15, function() data.State.IsInvincible = false end)
                task.delay(0.2, function() if bv.Parent then bv:Destroy() end end)
            end
        end
    elseif action == "Skill" then
        if data.Stats.SP < 50 then
            print("SP NOT ENOUGH: " .. data.Stats.SP)
            return
        end
        data.Stats.SP = data.Stats.SP - 50
        print("SKILL USED! SP: " .. data.Stats.SP)

        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in ipairs(enemies:GetChildren()) do
                        local er = enemy:FindFirstChild("HumanoidRootPart")
                        -- 半径を6に縮小
                        if er and (root.Position - er.Position).Magnitude <= 6 then
                            local dir = (er.Position - root.Position).Unit
                            dir = Vector3.new(dir.X, 0.3, dir.Z).Unit
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(50000, 50000, 50000)
                            -- ノックバックを40に縮小
                            bv.Velocity = dir * 40
                            bv.Parent = er
                            task.delay(0.25, function() if bv.Parent then bv:Destroy() end end)
                        end
                    end
                end
            end
        end
        UpdateStats:FireClient(player, data.Stats, data.State)
    end
end)

print("CombatServer READY")
