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

	explode = function(self)
		spark_data.spawn("tripop", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,5 do
			angle = love.math.random() * math.pi * 2
			v = 200 + 200 * love.math.random()
			spark_data.spawn("spark", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end
	end
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

	explode = function(self)
		spark_data.spawn("explosion", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,20 do
			angle = love.math.random() * math.pi * 2
			v = 200 + 200 * love.math.random()
			spark_data.spawn("spark", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end
	end
}

shot_data["buckshot"] =
{
	class = "buckshot", name = "Buckshot Pellet",
	damage = 10, duration = 0.2, duration_variance = 0.2,
	color = color.rouge,
	sprite = "bullet",
	half_w = 2, half_h = 2,

	explode = function(self)
		spark_data.spawn("tripop", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,5 do
			angle = love.math.random() * math.pi * 2
			v = 200 + 200 * love.math.random()
			spark_data.spawn("spark", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end
	end
}

return shot_data
