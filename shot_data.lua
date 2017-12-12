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
	end,

	facing = function(self)
		return math.atan2(self.dy, self.dx)
	end
}

shot_data["plasma"] =
{
	class = "plasma", name = "Plasma Sphere",
	damage = 240,
	color = color.yellow,
	sprite = "plasma",
	half_w = 6, half_h = 6,
	gravity_multiplier = 0.6,
	bounce_restitution = 0.8,
	collides_with_terrain = true, collides_with_actors = true,

	collide = function(self, hit, mx, my, mt, nx, ny)
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
				self:die(true)
			else
				-- reflect off
				local dot = self.dy * ny + self.dx * nx

				self.dx = (self.dx - 2 * dot * nx) * self.bounce_restitution
				self.dy = (self.dy - 2 * dot * ny) * self.bounce_restitution

				if not self.duration then
					self.duration = ctime - self.birth_time + 1
				end
			end
		elseif hit[1] == "enemy" then
			self:die()
		elseif hit[1] == "player" then
			self:die()
		end
	end,

	explode = function(self)
		local dist

		if self.faction == "player" then
			for j,z in pairs(enemies) do
				dist = mymath.dist(z.x, z.y, self.x, self.y)
				if dist < 128 then
					z:hurt(self.damage * (128 - dist) / 128)
				end
			end
		elseif self.faction == "enemy" then
			dist = mymath.dist(player.x, player.y, self.x, self.y)
			if dist < 128 then
				player:hurt(self.damage * (128 - dist) / 128)
			end
		end

		for i = map.grid_at_pos(self.x) - 5, map.grid_at_pos(self.x) + 5 do
			for j = map.grid_at_pos(self.y) - 5, map.grid_at_pos(self.y) + 5 do
				dist = mymath.dist(img.tile_size * (i + 0.5), img.tile_size * (j + 0.5), self.x, self.y)
				if dist < 128 then
					mainmap:hurt_block(i, j, self.damage * (128 - dist) / 128)
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

		audio.play('explosion')
		camera.shake(40)
	end,

	facing = function(self)
		return math.atan2(self.dy, self.dx)
	end
}

shot_data["buckshot"] =
{
	class = "buckshot", name = "Buckshot Pellet",
	damage = 10, duration = 0.2, duration_variance = 0.2, silent_timeout = true,
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
	end,

	facing = function(self)
		return math.atan2(self.dy, self.dx)
	end
}

shot_data["c4"] =
{
	class = "c4", name = "Remote Charge",
	damage = 240, silent_timeout = false,
	color = color.orange,
	sprite = "c4",
	half_w = 2, half_h = 2,
	gravity_multiplier = 0.6,
	collides_with_terrain = true, collides_with_actors = true,

	f = function(self)
		if self.attach_point then
			if self.attach_point[1] == "block" then
				if not mainmap:grid_has_collision(self.attach_point.i, self.attach_point.j) then
					-- block is gone, fall off
					local angle = love.math.random() * math.pi * 2
					local v = 20 + 100 * love.math.random()
					self.dx = v * math.cos(angle)
					self.dy = v * math.sin(angle)
					self.gravity_multiplier = 0.6
					self.collides_with_actors = true
					self.collides_with_terrain = true
					self.attach_point = nil
				end
			elseif self.attach_point[1] == "enemy" then
				if not enemies[self.attach_point.id] then
					-- enemy is gone, fall off
					local angle = love.math.random() * math.pi * 2
					local v = 20 + 100 * love.math.random()
					self.dx = v * math.cos(angle)
					self.dy = v * math.sin(angle)
					self.gravity_multiplier = 0.6
					self.collides_with_actors = true
					self.collides_with_terrain = true
					self.attach_point = nil
				else
					self.x = enemies[self.attach_point.id].x + self.attach_point.x_offset
					self.y = enemies[self.attach_point.id].y + self.attach_point.y_offset
				end
			end
		end
	end,

	collide = function(self, hit, mx, my, mt, nx, ny)
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
				self:die(true)
			else
				-- attach
				self.attach_point = {"block", i = hit[2], j = hit[3], facing = ((ctime - self.birth_time) % 1) * 2 * math.pi}
				self.dx = 0
				self.dy = 0
				self.gravity_multiplier = nil
				self.collides_with_actors = false
				self.collides_with_terrain = false

			end
		elseif hit[1] == "enemy" then
			-- attach
			self.attach_point = {"enemy", id = hit[2],
								 x_offset = self.x - enemies[hit[2]].x, y_offset = self.y - enemies[hit[2]].y,
								 facing = ((ctime - self.birth_time) % 1) * 2 * math.pi}
			self.dx = 0
			self.dy = 0
			self.gravity_multiplier = nil
			self.collides_with_actors = false
			self.collides_with_terrain = false
		elseif hit[1] == "player" then
			-- anh, fuck it
			self:die()
		end
	end,

	explode = function(self)
		local dist

		if self.faction == "player" then
			for j,z in pairs(enemies) do
				dist = mymath.dist(z.x, z.y, self.x, self.y)
				if dist < 128 then
					z:hurt(self.damage * (128 - dist) / 128)
				end
			end
		elseif self.faction == "enemy" then
			dist = mymath.dist(player.x, player.y, self.x, self.y)
			if dist < 128 then
				player:hurt(self.damage * (128 - dist) / 128)
			end
		end

		for i = map.grid_at_pos(self.x) - 5, map.grid_at_pos(self.x) + 5 do
			for j = map.grid_at_pos(self.y) - 5, map.grid_at_pos(self.y) + 5 do
				dist = mymath.dist(img.tile_size * (i + 0.5), img.tile_size * (j + 0.5), self.x, self.y)
				if dist < 128 then
					mainmap:hurt_block(i, j, self.damage * (128 - dist) / 128)
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

		audio.play('explosion')
		camera.shake(40)
	end,

	facing = function(self)
		if self.attach_point then
			return self.attach_point.facing
		else
			return ((ctime - self.birth_time) % 1) * 2 * math.pi
		end
	end
}

shot_data["missile"] =
{
	class = "missile", name = "Homing Missile",
	damage = 40,
	color = color.green,
	sprite = "missile",
	half_w = 3, half_h = 3,
	collides_with_terrain = true, collides_with_actors = true,
	homing_coefficient = 4, cruise_speed = 1000,

	f = function(self, dt)
		if ctime - self.birth_time > 0.2 then
			-- turn slowly towards the target
			local facing = math.atan2(self.dy, self.dx)
			local theta = 0
			if self.target_id and enemies[self.target_id] then
				theta = mymath.angle_difference(facing, math.atan2(enemies[self.target_id].y - self.y, enemies[self.target_id].x - self.x))
			end
			local new_speed = mymath.vector_length(self.dx, self.dy) * (1 - dt) + self.cruise_speed * (dt)
			self.dx = new_speed * math.cos(facing + theta * (math.min(1, self.homing_coefficient * dt)))
			self.dy = new_speed * math.sin(facing + theta * (math.min(1, self.homing_coefficient * dt)))

			if love.math.random() < 12 * dt then
				local angle = math.atan2(self.dy, self.dx) + math.pi
				v = 200 + 200 * love.math.random()
				spark_data.spawn("spark_s", self.color, self.x, self.y,
								 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
			end
		end
	end,

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
	end,

	facing = function(self)
		return math.atan2(self.dy, self.dx)
	end
}

return shot_data
