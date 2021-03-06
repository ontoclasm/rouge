local weapon_data = {}

function weapon_data.spawn(class)
	o = {}

	for i, v in pairs(weapon_data[class]) do
		o[i] = v
	end

	o.ammo = o.ammo_max

	return o
end


weapon_data["default"] =
{
	class = "default", name = "Assault Rifle", color = color.ltblue,
	shot = "pellet",
	sfx_fire = "gunfire1",
	ammo_max = 24, ammo_glyph = ".", reload_time = 0.8,
	shot_speed = 1100, shot_speed_variance = 200, cooldown = 0.10, recoil = 3, kick = 50,
	cof_min = 0, cof_max = 10, cof_growth = 10,

	fire_1 = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		local shot_angle = mymath.random_spread(angle, owner.cof)
		local shot_speed = self.shot_speed + self.shot_speed_variance * love.math.random()

		shot_data.spawn(self.shot, owner.x, owner.y,
						shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
						owner.name, owner.faction)

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(5, angle)
		end
	end
}

weapon_data["plasma"] =
{
	class = "plasma", name = "Plasma Gun", color = color.yellow,
	shot = "plasma",
	sfx_fire = "gunfire2",
	ammo_max = 6, ammo_glyph = "*", reload_time = 1.5,
	shot_speed = 300, shot_speed_distance_scaling = 1.2, shot_speed_max = 700, cooldown = 1, recoil = 30, kick = 218,
	cof_min = 5, cof_max = 40, cof_growth = 25,

	fire_1 = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		local shot_angle = mymath.random_spread(angle, owner.cof)
		local shot_speed = math.min(self.shot_speed + self.shot_speed_distance_scaling * mymath.dist(owner.x, owner.y, t_x, t_y),
									self.shot_speed_max)

		shot_data.spawn(self.shot, owner.x, owner.y,
						shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
						owner.name, owner.faction)

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(20, angle)
		end
	end
}

weapon_data["shotgun"] =
{
	class = "shotgun", name = "Shotgun", color = color.rouge,
	shot = "buckshot",
	sfx_fire = "gunfire2",
	ammo_max = 2, ammo_glyph = "!", reload_time = 0.8,
	shot_speed = 300, shot_speed_variance = 500, shot_count = 8, cooldown = 0.60, recoil = 40, kick = 218,
	cof_min = 15, cof_max = 15, cof_growth = 0,

	fire_1 = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		for k = 1, self.shot_count do
			local shot_angle = mymath.random_spread(angle, owner.cof)
			local shot_speed = self.shot_speed + self.shot_speed_variance * love.math.random()

			shot_data.spawn(self.shot, owner.x, owner.y,
							shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
							owner.name, owner.faction)
		end

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(5, angle)
		end
	end
}

weapon_data["c4 launcher"] =
{
	class = "c4 launcher", name = "C4 Launcher", color = color.orange,
	shot = "c4",
	sfx_fire = "gunfire2",
	ammo_max = 4, ammo_glyph = "[", reload_time = 1,
	shot_speed = 300, shot_speed_distance_scaling = 2, shot_speed_max = 800, cooldown = 1, recoil = 30, kick = 218,
	cof_min = 5, cof_max = 40, cof_growth = 25,
	shot_ids = {},

	fire_1 = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		local shot_angle = mymath.random_spread(angle, owner.cof)
		local shot_speed = math.min(self.shot_speed + self.shot_speed_distance_scaling * mymath.dist(owner.x, owner.y, t_x, t_y),
									self.shot_speed_max)

		local shot_id = shot_data.spawn(self.shot, owner.x, owner.y,
										shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
										owner.name, owner.faction)

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		table.insert(self.shot_ids, shot_id)

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(20, angle)
		end
	end,

	fire_2 = function(self, owner, t_x, t_y)
		for _,v in ipairs(self.shot_ids) do
			-- they might have been nixed some other way
			if shots[v] then
				shots[v].duration = ctime - shots[v].birth_time + 0.2 * love.math.random()
			end
		end
		self.shot_ids = {}
	end
}

weapon_data["missile"] =
{
	class = "missile", name = "Missile Launcher", color = color.green,
	shot = "missile",
	sfx_fire = "gunfire2",
	ammo_max = 5, ammo_glyph = "I", reload_time = 0.8,
	shot_speed = 300, cooldown = 0.40, recoil = 30, kick = 218,
	cof_min = 20, cof_max = 60, cof_growth = 25,

	fire_1 = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		local shot_angle = mymath.random_spread(angle, owner.cof)
		local shot_speed = self.shot_speed

		local shot_id = shot_data.spawn(self.shot, owner.x, owner.y,
										shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
										owner.name, owner.faction)

		-- acquire the target closest to aim point
		local closest_id = nil
		local closest_dist = 99999
		local dist
		for j,z in pairs(enemies) do
			dist = mymath.dist(z.x, z.y, t_x, t_y)
			if dist < closest_dist then
				closest_id = j
				closest_dist = dist
			end
		end

		if closest_id then
			shots[shot_id].target_id = closest_id
		end

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(5, angle)
		end
	end
}

weapon_data["laser"] =
{
	class = "laser", name = "Laser Beam", color = color.actinic,
	sfx_fire = "laser",
	ammo_max = 100, ammo_glyph = "-", reload_time = 1.5, -- no ammo?
	cooldown = 0.01, recoil = 0, kick = 0,
	cof_min = 0, cof_max = 0, cof_growth = 0,
	beam_length = 2000, damage = 10,

	fire_1 = function(self, owner, t_x, t_y)
		local vx = self.beam_length * math.cos(math.atan2(t_y - owner.y, t_x - owner.x))
		local vy = self.beam_length * math.sin(math.atan2(t_y - owner.y, t_x - owner.x))
		local box = {x = owner.x, y = owner.y, half_w = 2, half_h = 2}
		-- local shot_angle = mymath.random_spread(angle, owner.cof)

		--"infinite" line
		hit, mx, my, mt, nx, ny = physics.map_collision_aabb_sweep(box, vx, vy)

		local hx, hy, ht
		if owner.faction == "player" then
			for j,z in pairs(enemies) do
				hx, hy, ht = physics.collision_aabb_sweep(box, z, vx, vy)
				if ht and ht < mt then
					hit = {"enemy", j}
					mt, mx, my = ht, hx, hy
				end
			end
		elseif owner.faction == "enemy" then
			hx, hy, ht = physics.collision_aabb_sweep(box, player, vx, vy)
			if ht and ht < mt then
				hit = {"player"}
				mt, mx, my = ht, hx, hy
			end
		end

		beam_data.spawn(owner.x, owner.y, mx, my, self.color, 4, 0.2)

		if hit then
			if hit[1] == "block" then
				mainmap:hurt_block(hit[2], hit[3], self.damage)
			elseif hit[1] == "enemy" then
				enemies[hit[2]]:hurt(self.damage)
				camera.shake(10)
			elseif hit[1] == "player" then
				player:hurt(self.damage)
				camera.shake(10)
			end

			spark_data.spawn("tripop", self.color, mx, my,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
			for i=1,5 do
				angle = love.math.random() * math.pi * 2
				v = 200 + 200 * love.math.random()
				spark_data.spawn("spark_s", self.color, mx, my,
								 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
			end
		end

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		-- if owner.cof_factor < 100 then
		-- 	owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		-- end

		-- kick in the opposite direction. kick vertically only if airborne
		-- owner.dx = owner.dx - self.kick * math.cos(angle)
		-- if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(5, angle)
		end
	end
}

return weapon_data
