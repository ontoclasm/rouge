local shot_data = {}

function shot_data.spawn(class, x, y, dx, dy, owner, faction)
	local pid = idcounter.get_id("shot")
	shots[pid] = shot:new({
		id = pid,
		dx = dx, dy = dy, owner = owner, faction = faction
	})

	for i, v in pairs(shot_data[class]) do
		shots[pid][i] = v
	end

	shots[pid].x, shots[pid].y = x, y
	shots[pid].birth_time = ctime

	return pid
end

shot_data["pellet"] =
{
	class = "pellet", name = "Machine Gun Bullet",
	damage = 20,
	color = color.ltblue,
	half_w = 2, half_h = 2,
	gravity_multiplier = 1,
	bounces = 1, bounce_restitution = 0.8,
}

shot_data["plasma"] =
{
	class = "plasma", name = "Plasma Sphere",
	damage = 60,
	color = color.yellow,
	half_w = 6, half_h = 6,
}

shot_data["buckshot"] =
{
	class = "buckshot", name = "Buckshot Pellet",
	damage = 10, duration = 0.2,
	color = color.rouge,
	half_w = 2, half_h = 2,
}

return shot_data
