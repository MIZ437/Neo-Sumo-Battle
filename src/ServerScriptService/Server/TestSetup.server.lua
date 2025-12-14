-- テスト用セットアップ
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")

local EnemyFactory = require(Modules:WaitForChild("EnemyFactory"))
local PlayerData = require(Modules:WaitForChild("PlayerData"))

local EnemiesFolder = Workspace:WaitForChild("Enemies")
local Arena = Workspace:WaitForChild("Arena")

-- テスト用コマンド
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local args = string.split(message, " ")
		local cmd = args[1]:lower()

		-- /spawn [stage] - 敵を召喚
		if cmd == "/spawn" then
			local stage = tonumber(args[2]) or 1

			-- 既存の敵を削除
			for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
				enemy:Destroy()
			end

			local spawnPos = Vector3.new(15, 10, 0)
			local enemy

			if stage == 10 then
				enemy = EnemyFactory.CreateBoss("GrassGolem", spawnPos)
			else
				enemy = EnemyFactory.CreateStageEnemy(stage, spawnPos)
			end
			enemy.Parent = EnemiesFolder

			print("✅ 敵生成: ステージ " .. stage)

		-- /level [num] - レベル設定
		elseif cmd == "/level" then
			local level = tonumber(args[2]) or 1
			local data = PlayerData.Get(player)
			if data then
				data.Level = level
				data:ApplyLevelStats()
				print("✅ レベル設定: " .. level)
			end

		-- /hp [amount] - HP回復
		elseif cmd == "/hp" then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = humanoid.MaxHealth
					print("✅ HP全回復")
				end
			end

		-- /clear - ステージ全クリア
		elseif cmd == "/clear" then
			local data = PlayerData.Get(player)
			if data then
				data.MaxStageCleared = 10
				print("✅ 全ステージ解放")
			end
		end
	end)
end)

print("🔧 テストコマンド有効")
print("  /spawn [stage] - 敵召喚")
print("  /level [num] - レベル設定")
print("  /hp - HP回復")
print("  /clear - 全ステージ解放")
