-- Neo Sumo Battle - ショップサーバー
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = ReplicatedStorage:WaitForChild("Config")

local PlayerData = require(Modules:WaitForChild("PlayerData"))
local GameConfig = require(Config:WaitForChild("GameConfig"))

local UpgradeStat = Events:WaitForChild("UpgradeStat")
local GetUpgradeInfo = Events:WaitForChild("GetUpgradeInfo")
local GetPlayerStats = Events:WaitForChild("GetPlayerStats")

-- 強化処理
UpgradeStat.OnServerEvent:Connect(function(player, statName)
	local data = PlayerData.Get(player)
	if not data then return end

	local success, message = data:UpgradeStat(statName)

	-- 結果をクライアントに通知
	UpgradeStat:FireClient(player, {
		success = success,
		message = message,
		statName = statName,
		newLevel = data.Upgrades[statName],
		coins = data.Coins,
	})

	print("🛒 " .. player.Name .. " " .. statName .. " 強化: " .. message)
end)

-- 強化情報取得
GetUpgradeInfo.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then return nil end

	local info = {}
	for statName, _ in pairs(GameConfig.Upgrades) do
		info[statName] = data:GetUpgradeInfo(statName)
	end

	return {
		upgrades = info,
		coins = data.Coins,
		level = data.Level,
	}
end

-- プレイヤーステータス取得
GetPlayerStats.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then return nil end

	return {
		level = data.Level,
		exp = data.Exp,
		coins = data.Coins,
		crystals = data.Crystals,
		maxStageCleared = data.MaxStageCleared,
		stats = data.Stats,
		upgrades = data.Upgrades,
	}
end

print("🛒 ショップサーバー起動")
