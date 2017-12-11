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
			self:die(self.silent_timeout)
		end
	end

	if self.gravity_multiplier then
		self.dy = self.dy + (self.gravity_multiplier * gravity * dt)
	end

	-- collide: first with tiles, then mobs
	if self.collides_with_terrain then
		hit, mx, my, mt, nx, ny = physics.map_collision_aabb_sweep(self, self.dx * dt, self.dy * dt)
	else
		hit = nil
		mx, my = self.x + self.dx * dt, self.y + self.dy * dt
		mt = 1
		nx, ny = 0, 0
	end

	if self.collides_with_actors then
		if self.faction == "player" then
			for j,z in pairs(enemies) do
				if math.abs(self.x - z.x) <= 64 and math.abs(self.y - z.y) <= 64 then
					hx, hy, ht = physics.collision_aabb_sweep(self, z, self.dx * dt, self.dy * dt)
					if ht and ht < mt then
						hit = {"enemy", j}
						mt, mx, my = ht, hx, hy
					end
				end
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
		self:collide(hit, mx, my, mt, nx, ny)
	end
end

function shot:die(silent)
	if not silent then
		self:explode()
	end
	shots[self.id] = nil
end

function shot:draw()
	love.graphics.setColor(self.color)

	img.draw_rotational_sprite(self.sprite, 1, camera.view_x(self), camera.view_y(self), self:facing())
end

return shot
