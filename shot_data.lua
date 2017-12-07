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

	if shots[pid]["duration_variance"] then
		shots[pid]["duration"] = shots[pid]["duration"] + shots[pid]["duration_variance"] * love.math.random()
	end

	return pid
end

shot_data["pellet"] =
{
	class = "pellet", name = "Machine Gun Bullet",
	damage = 20,
	color = color.ltblue,
	sprite = "bullet",
	half_w = 2, half_h = 2,
}

shot_data["plasma"] =
{
	class = "plasma", name = "Plasma Sphere",
	damage = 60,
	color = color.yellow,
	sprite = "plasma",
	half_w = 6, half_h = 6,
	gravity_multiplier = 0.6,
	bounces = 3, bounce_restitution = 0.8,
}

shot_data["buckshot"] =
{
	class = "buckshot", name = "Buckshot Pellet",
	damage = 10, duration = 0.2, duration_variance = 0.2,
	color = color.rouge,
	sprite = "bullet",
	half_w = 2, half_h = 2,
}

return shot_data
