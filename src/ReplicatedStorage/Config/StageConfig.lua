-- Neo Sumo Battle - ステージ設定（MVP: 草原10ステージ）
local StageConfig = {}

StageConfig.Theme = {
	Name = "草原",
	GroundColor = Color3.fromRGB(34, 139, 34),
	AccentColor = Color3.fromRGB(139, 90, 43),
	Skybox = "Day",
}

StageConfig.Stages = {}

-- ステージ1〜9: 通常敵
for i = 1, 9 do
	StageConfig.Stages[i] = {
		Id = i,
		Name = "ステージ " .. i,
		IsBoss = false,
		ArenaRadius = 25 - (i - 1) * 0.5, -- 徐々に狭くなる
		Gimmicks = {},
	}

	-- ステージごとにギミック追加
	if i >= 3 then
		table.insert(StageConfig.Stages[i].Gimmicks, "Grass") -- 草むら
	end
	if i >= 5 then
		table.insert(StageConfig.Stages[i].Gimmicks, "Rock") -- 岩
	end
	if i >= 7 then
		table.insert(StageConfig.Stages[i].Gimmicks, "Tree") -- 木
	end
end

-- ステージ10: ボス戦
StageConfig.Stages[10] = {
	Id = 10,
	Name = "ボス: 草ゴーレム",
	IsBoss = true,
	ArenaRadius = 30, -- ボス戦は広め
	Gimmicks = {"Grass", "Rock", "Tree"},
	Boss = {
		Name = "草ゴーレム",
		Scale = 2,
		HP = 500,
		Power = 20,
		Stability = 25,
		Skills = {"BodyPress", "GrassSpawn"},
	},
}

function StageConfig.GetStage(id)
	return StageConfig.Stages[id]
end

return StageConfig
