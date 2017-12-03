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

	shots[pid].x, shots[pid].y = x - shots[pid].w /2, y - shots[pid].h /2
	shots[pid].birth_time = ctime

	return pid
end

shot_data["pellet"] =
{
	class = "pellet", name = "Machine Gun Bullet",
	damage = 20,
	color = color.ltblue,
	w = 4, h = 4
}

shot_data["plasma"] =
{
	class = "plasma", name = "Plasma Sphere",
	damage = 60,
	color = color.yellow,
	w = 12, h = 12
}

shot_data["buckshot"] =
{
	class = "buckshot", name = "Buckshot Pellet",
	damage = 10, duration = 0.2,
	color = color.rouge,
	w = 2, h = 2
}

return shot_data
