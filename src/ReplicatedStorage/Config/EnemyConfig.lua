-- Neo Sumo Battle - 敵AI設定（12タイプ）
local EnemyConfig = {}

-- 目的タイプ
EnemyConfig.Goals = {
	Killer = "HP削り優先",
	Pusher = "落とし優先",
	Smart = "状況判断",
}

-- スタイルタイプ
EnemyConfig.Styles = {
	Aggressive = {attackRate = 0.8, guardRate = 0.1},
	Defensive = {attackRate = 0.3, guardRate = 0.5},
	Balanced = {attackRate = 0.5, guardRate = 0.3},
	Speedy = {attackRate = 0.6, guardRate = 0.2, speedMult = 1.3},
}

-- 12タイプの組み合わせ
EnemyConfig.Types = {
	{id = 1, goal = "Killer", style = "Aggressive", name = "猛攻型"},
	{id = 2, goal = "Killer", style = "Defensive", name = "堅実型"},
	{id = 3, goal = "Killer", style = "Balanced", name = "安定型"},
	{id = 4, goal = "Killer", style = "Speedy", name = "疾風型"},
	{id = 5, goal = "Pusher", style = "Aggressive", name = "強引型"},
	{id = 6, goal = "Pusher", style = "Defensive", name = "待機型"},
	{id = 7, goal = "Pusher", style = "Balanced", name = "追込型"},
	{id = 8, goal = "Pusher", style = "Speedy", name = "回込型"},
	{id = 9, goal = "Smart", style = "Aggressive", name = "全力型"},
	{id = 10, goal = "Smart", style = "Defensive", name = "確実型"},
	{id = 11, goal = "Smart", style = "Balanced", name = "万能型"},
	{id = 12, goal = "Smart", style = "Speedy", name = "逃走型"},
}

-- 難易度設定（ステージごと）
EnemyConfig.Difficulty = {
	BaseAccuracy = 0.4, -- ステージ1
	AccuracyPerStage = 0.04, -- ステージごとの上昇
	StatMultiplierPerStage = 0.02, -- ステータス倍率
}

function EnemyConfig.GetType(id)
	return EnemyConfig.Types[id]
end

function EnemyConfig.GetRandomType()
	return EnemyConfig.Types[math.random(1, #EnemyConfig.Types)]
end

function EnemyConfig.GetDifficulty(stage)
	local accuracy = EnemyConfig.Difficulty.BaseAccuracy +
		(stage - 1) * EnemyConfig.Difficulty.AccuracyPerStage
	accuracy = math.min(accuracy, 0.8) -- 最大80%

	local statMult = 1 + (stage - 1) * EnemyConfig.Difficulty.StatMultiplierPerStage

	return {
		accuracy = accuracy,
		statMultiplier = statMult * 1.2, -- 適正の120%
	}
end

return EnemyConfig
