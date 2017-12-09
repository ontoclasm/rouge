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
	bounce_restitution = 0.8,
	collides_with_terrain = true, collides_with_actors = true,

	collide = function(self, hit, mx, my, mt, nx, ny)
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
					self:die(true)
			else
				-- reflect off, maybe
				-- chance is based on the angle of incidence
				local dot = self.dy * ny + self.dx * nx
				if (love.math.random() * math.pi) < 2 * math.abs(math.acos(dot / mymath.vector_length(self.dx, self.dy)) - math.pi) - 0.2 then
					self.dx = (self.dx - 2 * dot * nx) * self.bounce_restitution
					self.dy = (self.dy - 2 * dot * ny) * self.bounce_restitution
				else
					mainmap:hurt_block(hit[2], hit[3], self.damage)
					self:die()
					audio.play('hit2')
				end
			end
		elseif hit[1] == "enemy" then
			enemies[hit[2]]:hurt(self.damage)
			self:die()
			audio.play('hit1')
			camera.shake(10)
		elseif hit[1] == "player" then
			player:hurt(self.damage)
			self:die()
			audio.play('hit1')
			camera.shake(10)
		end
	end,

	explode = function(self)
		spark_data.spawn("tripop", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,5 do
			angle = love.math.random() * math.pi * 2
			v = 200 + 200 * love.math.random()
			spark_data.spawn("spark_s", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end
	end
}

shot_data["plasma"] =
{
	class = "plasma", name = "Plasma Sphere",
	damage = 120,
	color = color.yellow,
	sprite = "plasma",
	half_w = 6, half_h = 6,
	gravity_multiplier = 0.6,
	bounces = 3, bounce_restitution = 0.8,
	collides_with_terrain = true, collides_with_actors = true,

	collide = function(self, hit, mx, my, mt, nx, ny)
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
					self:die(true)
			elseif self.bounces > 0 then
				-- reflect off
				local dot = self.dy * ny + self.dx * nx

				self.dx = (self.dx - 2 * dot * nx) * self.bounce_restitution
				self.dy = (self.dy - 2 * dot * ny) * self.bounce_restitution

				self.bounces = self.bounces - 1
			elseif self.damage then
				self:die()
				audio.play('hit2')
				camera.shake(25)
			end
		elseif hit[1] == "enemy" then
			self:die()
			audio.play('hit1')
			camera.shake(40)
		elseif hit[1] == "player" then
			self:die()
			audio.play('hit1')
			camera.shake(40)
		end
	end,

	explode = function(self)
		local dist

		if self.faction == "player" then
			for j,z in pairs(enemies) do
				dist = mymath.dist(z.x, z.y, self.x, self.y)
				if dist < 64 then
					z:hurt(self.damage * (64 - dist) / 64)
				end
			end
		elseif self.faction == "enemy" then
			dist = mymath.dist(player.x, player.y, self.x, self.y)
			if dist < 64 then
				player:hurt(self.damage * (64 - dist) / 64)
			end
		end

		for i = map.grid_at_pos(self.x) - 3, map.grid_at_pos(self.x) + 3 do
			for j = map.grid_at_pos(self.y) - 3, map.grid_at_pos(self.y) + 3 do
				dist = mymath.dist(img.tile_size * (i + 0.5), img.tile_size * (j + 0.5), self.x, self.y)
				if dist < 64 then
					mainmap:hurt_block(i, j, self.damage * (64 - dist) / 64)
				end
			end
		end


		spark_data.spawn("explosion", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,14 do
			angle = love.math.random() * math.pi * 2
			v = 100 + 500 * love.math.random()
			spark_data.spawn("spark_s", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end

		for i=1,7 do
			angle = love.math.random() * math.pi * 2
			v = 80 + 400 * love.math.random()
			spark_data.spawn("spark_m", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end

		for i=1,4 do
			angle = love.math.random() * math.pi * 2
			v = 50 + 300 * love.math.random()
			spark_data.spawn("spark_l", self.color, self.x, self.y,
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
	collides_with_terrain = false, collides_with_actors = true,

	collide = function(self, hit, mx, my, mt, nx, ny)
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
					self:die(true)
			else
				mainmap:hurt_block(hit[2], hit[3], self.damage)
				self:die()
				audio.play('hit2')
			end
		elseif hit[1] == "enemy" then
			enemies[hit[2]]:hurt(self.damage)
			self:die()
			audio.play('hit1')
			camera.shake(10)
		elseif hit[1] == "player" then
			player:hurt(self.damage)
			self:die()
			audio.play('hit1')
			camera.shake(10)
		end
	end,

	explode = function(self)
		spark_data.spawn("tripop", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,5 do
			angle = love.math.random() * math.pi * 2
			v = 200 + 200 * love.math.random()
			spark_data.spawn("spark_s", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end
	end
}

return shot_data
