-- Neo Sumo Battle - スキル設定（MVP: 3スキル）
local SkillConfig = {}

SkillConfig.Skills = {
	{
		Id = 1,
		Name = "Power Push",
		Description = "押す力が2倍になる（5秒間）",
		SPCost = 50,
		Cooldown = 5,
		Duration = 5,
		Effect = "PowerBoost",
		Multiplier = 2,
		Icon = "rbxassetid://6034287594",
	},
	{
		Id = 2,
		Name = "Speed Boost",
		Description = "移動速度が2倍になる（8秒間）",
		SPCost = 50,
		Cooldown = 10,
		Duration = 8,
		Effect = "SpeedBoost",
		Multiplier = 2,
		Icon = "rbxassetid://6034684930",
	},
	{
		Id = 3,
		Name = "Heal",
		Description = "HPを35%回復する",
		SPCost = 50,
		Cooldown = 20,
		Duration = 0,
		Effect = "Heal",
		Multiplier = 0.35,
		Icon = "rbxassetid://6034767657",
	},
}

function SkillConfig.GetSkill(id)
	for _, skill in ipairs(SkillConfig.Skills) do
		if skill.Id == id then
			return skill
		end
	end
	return nil
end

return SkillConfig
