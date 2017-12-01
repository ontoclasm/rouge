local enemy_data = {}

function enemy_data.spawn(class, x, y, f)
	local pid = idcounter.get_id("enemy")
	enemies[pid] = actor:new({
		id = pid,
		x = x, y = y, facing = f,
		faction = "enemy", ai = {control = "enemy"},
		dx = 0, dy = 0, controls = {}, status = {},
		anim_start = ctime, flash_color = color.white, flash_time = 0,
		shot_cooldown = 0, cof = 0, cof_factor = 0,
		touching_floor = false, double_jumps = 0, dash_cooldown = 0
	})

	for i, v in pairs(enemy_data[class]) do
		enemies[pid][i] = v
	end

	enemies[pid].weapon = weapon_data.spawn(enemies[pid].weapon_class)
	if enemies[pid].ai_routine then
		ai.setup(enemies[pid], enemies[pid].ai_routine)
	end

	return pid
end

enemy_data["bird"] =
{
	class = "bird",
	w = 16, h = 16,
	sprite = "demon", color = color.blue,
	hp = 60, weapon_class = "default",
	ai_routine = "flyer", ai_sequence = "fly around",
	top_speed = 100, walk_accel = 600, walk_friction = 500,
	jump_speed = 300, air_accel = 700,
	dash_speed = 700, dash_dur = 0.3,
	double_jumps_max = 1, flies = true
}

enemy_data["demon"] =
{
	class = "demon",
	w = 16, h = 16,
	sprite = "demon", color = color.blue,
	hp = 60, weapon_class = "shotgun",
	ai_routine = "walker",
	top_speed = 100, walk_accel = 600, walk_friction = 500,
	jump_speed = 300, air_accel = 700,
	dash_speed = 700, dash_dur = 0.3,
	double_jumps_max = 1, flies = true
}

return enemy_data
