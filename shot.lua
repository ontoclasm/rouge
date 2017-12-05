local shot = {}

function shot:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

local hit, mx, mt, mt, nx, ny
function shot:update(dt)
	-- if we have a special update function, run it
	if self.f ~= nil then self.f(self, dt) end

	if self.duration ~= nil then
		if ctime > self.birth_time + self.duration then
			self:die(true)
		end
	end

	if self.gravity_multiplier then
		self.dy = self.dy + (self.gravity_multiplier * gravity * dt)
	end

	-- collide: first with tiles, then mobs
	hit, mx, my, mt, nx, ny = physics.map_collision_aabb_sweep(self, self.dx * dt, self.dy * dt)

	if self.damage then
		if self.faction == "player" then
			for j,z in pairs(enemies) do
				-- if math.abs(self.x - z.x) <= 64 and math.abs(self.y - z.y) <= 64 then
				hx, hy, ht = physics.collision_aabb_sweep(self, z, self.dx * dt, self.dy * dt)
				if ht and ht < mt then
					hit = {"enemy", j}
					mt, mx, my = ht, hx, hy
				end
				-- end
			end
		elseif self.faction == "enemy" then
			hx, hy, ht = physics.collision_aabb_sweep(self, player, self.dx * dt, self.dy * dt)
			if ht and ht < mt then
				hit = {"player"}
				mt, mx, my = ht, hx, hy
			end
		end
	end

	self.x = mx
	self.y = my

	-- now, if we hit something, react
	if hit then
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
					self:die(true)
			elseif self.bounces and self.bounces > 0 then
				-- reflect off
				local dot = self.dy * ny + self.dx * nx

				self.dx = (self.dx - 2 * dot * nx) * self.bounce_restitution
				self.dy = (self.dy - 2 * dot * ny) * self.bounce_restitution

				self.bounces = self.bounces - 1
			elseif self.damage then
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
	end
end

function shot:die(silent)
	if not silent then
		spark_data.spawn("tripop", self.color, self.x, self.y,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
		for i=1,5 do
			angle = love.math.random() * math.pi * 2
			v = 200 + 200 * love.math.random()
			spark_data.spawn("spark", self.color, self.x, self.y,
							 v * math.cos(angle), v * math.sin(angle), 0, 1, 1)
		end
	end
	shots[self.id] = nil
end

function shot:draw()
	love.graphics.setColor(self.color)
	angle = (mymath.round(math.atan2(self.dy, self.dx) * 8 / math.pi)) % 8 -- remember y+ (i.e. pi/2) is DOWN :suicide:
	if angle == 0 or angle == 8 then
		love.graphics.draw(img.tileset, img.tile["bullet_0"][1],
						   camera.view_x(self), camera.view_y(self), 0, 1, 1,
						   16, 16)
	elseif angle == 1 then
		love.graphics.draw(img.tileset, img.tile["bullet_23"][1],
						   camera.view_x(self), camera.view_y(self), 0, 1, 1,
						   16, 16)
	elseif angle == 2 then
		love.graphics.draw(img.tileset, img.tile["bullet_45"][1],
						   camera.view_x(self), camera.view_y(self), 0, 1, 1,
						   16, 16)
	elseif angle == 3 then
		love.graphics.draw(img.tileset, img.tile["bullet_23"][1],
						   camera.view_x(self), camera.view_y(self), math.pi / 2, -1, 1,
						   16, 16)
	elseif angle == 4 then
		love.graphics.draw(img.tileset, img.tile["bullet_0"][1],
						   camera.view_x(self), camera.view_y(self), math.pi / 2, 1, 1,
						   16, 16)
	elseif angle == 5 then
		love.graphics.draw(img.tileset, img.tile["bullet_23"][1],
						   camera.view_x(self), camera.view_y(self), math.pi / 2, 1, 1,
						   16, 16)
	elseif angle == 6 then
		love.graphics.draw(img.tileset, img.tile["bullet_45"][1],
						   camera.view_x(self), camera.view_y(self), math.pi / 2, 1, 1,
						   16, 16)
	elseif angle == 7 then
		love.graphics.draw(img.tileset, img.tile["bullet_23"][1],
						   camera.view_x(self), camera.view_y(self), 0, 1, -1,
						   16, 16)
	end
end

return shot
