local physics = {}

local ax, bx, pad_x, sign_x, ay, by, pad_y, sign_y
local near_time_x, far_time_x, near_time_y, far_time_y, far_time
local hit_time, hit_x, hit_y, nx, ny

--- test if moving a by (vx,vy) will cause it to hit b
-- if so, return x,y (point of impact), 0 <= t <= 1 ("time" of impact), nx,ny (normal of the surface we ran into)
function physics.collision_aabb_sweep(a, b, vx, vy)
	ax, bx =  a.x + a.w/2, b.x + b.w/2
	pad_x = b.w/2 + a.w/2
	sign_x = mymath.sign(vx)

	ay, by =  a.y + a.h/2, b.y + b.h/2
	pad_y = b.h/2 + a.h/2
	sign_y = mymath.sign(vy)

	if vx ~= 0 then
		scale_x = 1 / vx
		near_time_x = (bx - sign_x * (pad_x) - ax) * scale_x
		far_time_x = (bx + sign_x * (pad_x) - ax) * scale_x
	else
		if ax > bx - pad_x and ax < bx + pad_x then
			near_time_x, far_time_x = -9999, 9999
		else
			return
		end
	end

	if vy ~= 0 then
		scale_y = 1 / vy
		near_time_y = (by - sign_y * (pad_y) - ay) * scale_y
		far_time_y = (by + sign_y * (pad_y) - ay) * scale_y
	else
		if ay > by - pad_y and ay < by + pad_y then
			near_time_y, far_time_y = -9999, 9999
		else
			return
		end
	end

	if near_time_x > far_time_y or near_time_y > far_time_x then
		-- missed
		return
	end

	-- pick the times we were closest
	near_time = math.max(near_time_x, near_time_y)
	far_time = math.min(far_time_x, far_time_y)

	if near_time > 1 or far_time < 0 then
		-- didn't reach b, or already past and moving away
		return
	end

	-- okay, we hit the aabb
	hit_time = mymath.clamp(0, near_time, 1)
	if near_time_x > near_time_y then
		nx = -sign_x
		ny = 0
	else
		nx = 0
		ny = -sign_y
	end

	hit_x = a.x + hit_time * vx - 0.001 * sign_x
	hit_y = a.y + hit_time * vy - 0.001 * sign_y

	return hit_x, hit_y, hit_time, nx, ny
end

local rx, ry, norm

function physics.collision_aabb_sweep_slope(a, b, slope, slope_y_offset, vx, vy)
	ax, bx =  a.x + a.w/2, b.x + b.w/2
	pad_x = b.w/2 + a.w/2
	sign_x = mymath.sign(vx)
	scale_x = 1 / vx

	ay, by =  a.y + a.h/2, b.y + b.h/2
	pad_y = b.h/2 + a.h/2
	sign_y = mymath.sign(vy)
	scale_y = 1 / vy

	if vx ~= 0 then
		near_time_x = (bx - sign_x * (pad_x) - ax) * scale_x
		far_time_x = (bx + sign_x * (pad_x) - ax) * scale_x
	else
		if ax > bx - pad_x and ax < bx + pad_x then
			near_time_x, far_time_x = -9999, 9999
		else
			return
		end
	end

	if vy ~= 0 then
		near_time_y = (by - sign_y * (pad_y) - ay) * scale_y
		far_time_y = (by + sign_y * (pad_y) - ay) * scale_y
	else
		if ay > by - pad_y and ay < by + pad_y then
			near_time_y, far_time_y = -9999, 9999
		else
			return
		end
	end

	if near_time_x > far_time_y or near_time_y > far_time_x then
		-- missed the whole box
		return
	end

	-- ugh, now deal with the slanted edge

	-- coords of the relevant corner of a; currently this is always a bottom corner
	rx = ax - a.w * mymath.sign(slope) / 2
	ry = ay + a.h / 2

	if vx ~= 0 then
		-- find the x distance traveled; divide by vx to find near_time_q
		vslope = vy / vx

		-- x coord of the contact point is (1/(slope - vslope))(slope * bx - by - vslope * rx + ry)
		near_time_q = ((slope * bx - by - slope_y_offset - vslope * rx + ry) / (slope - vslope) - rx) * scale_x
	else
		-- x is fixed: find the y distance and divide by vy to find near_time_q

		-- y coord of the contact point is (slope * (rx - bx) + by)
		near_time_q = (slope * (rx - bx) + by + slope_y_offset - ry) * scale_y
	end

	if ry > slope * (rx - bx) + by + slope_y_offset then
		if near_time_q < 0 then
			-- below and moving away
			far_time_q = 9999
		else
			-- below, but moving out of the slope
			far_time_q = near_time_q
			near_time_q = -9999
		end
	else
		if near_time_q < 0 then
			-- above, but moving away
			return
		else
			-- above, and moving towards
			far_time_q = 9999
		end
	end

	if near_time_q > far_time_x or near_time_q > far_time_y or near_time_x > far_time_q or near_time_y > far_time_q then
		-- missed again, rip
		return
	end

	-- pick the times we were closest
	near_time = math.max(near_time_x, near_time_y, near_time_q)
	far_time = math.min(far_time_x, far_time_y, far_time_q)

	if near_time > 1 or far_time < 0 then
		-- didn't reach b, or already past and moving away
		return
	end

	-- okay?????
	hit_time = mymath.clamp(0, near_time, 1)
	if near_time_q > near_time_x and near_time_q > near_time_y then
		-- normal to the slope
		norm = math.sqrt(math.pow(slope, 2) + 1)
		nx = slope / norm
		ny = - 1 / norm

		hit_x = a.x + hit_time * vx - 0.001 * sign_x
		hit_y = a.y + hit_time * vy - 0.001 * sign_y
	else
		if near_time_x > near_time_y then
			nx = -sign_x
			ny = 0
		else
			nx = 0
			ny = -sign_y
		end

		hit_x = a.x + hit_time * vx - 0.001 * sign_x
		hit_y = a.y + hit_time * vy - 0.001 * sign_y
	end

	return hit_x, hit_y, hit_time, nx, ny
end

-------------

local grid_x1, grid_x2, grid_y1, grid_y2
local block_type
local box
local hit
local mx, my, mt, mnx, mny

function physics.map_collision_aabb_sweep(a, vx, vy)
	grid_x1 = map.grid_at_pos(math.min(a.x, a.x + vx))
	grid_x2 = map.grid_at_pos(math.max(a.x + a.w, a.x + a.w + vx))
	grid_y1 = map.grid_at_pos(math.min(a.y, a.y + vy))
	grid_y2 = map.grid_at_pos(math.max(a.y + a.h, a.y + a.h + vy))

	-- local grid_x1 = 1
	-- local grid_x2 = mainmap.width - 1
	-- local grid_y1 = 1
	-- local grid_y2 = mainmap.width - 1

	mt = 1
	hit = nil
	for i = grid_x1, grid_x2 do
		for j = grid_y1, grid_y2 do
			if mainmap:grid_has_collision(i, j) then
				block_type = mainmap:block_at(i, j)
				box = map.bounding_box(i, j)

				if block_data[block_type].slope then
					hx, hy, ht, nx, ny = physics.collision_aabb_sweep_slope(a, box, block_data[block_type].slope,
																			block_data[block_type].slope_y_offset, vx, vy)
				else
					hx, hy, ht, nx, ny = physics.collision_aabb_sweep(a, box, vx, vy)
				end

				--  and not mainmap:grid_blocks_dir(i + nx, j + ny, map.orth_normal_to_dir(-nx, -ny))
				if ht and ht < mt then
					if (nx ~= 0 and ny ~= 0) or not mainmap:grid_blocks_dir(i + nx, j + ny, map.orth_normal_to_dir(-nx, -ny)) then
						hit = {"block", i, j}
						mt = ht
						mx = hit_x
						my = hit_y
						mnx = nx
						mny = ny
						if nx > 0 then
							mx = math.ceil(mx)
						elseif nx < 0 then
							mx = math.floor(mx)
						end
						if ny > 0 then
							my = math.ceil(my)
						elseif ny < 0 then
							my = math.floor(my)
						end
					end
				end
			end
		end
	end

	if not hit then
		mx, my = a.x + vx, a.y + vy
		mnx, mny = 0, 0
	end

	return hit, mx, my, mt, mnx, mny
end

local vx, vy
local ijhx, ijhy, ijht, ijnx, ijny
local rt, rvx, rvy

function physics.map_collision_test(a)
	vx = mouse.x + camera.x - a.x - a.w/2
	vy = mouse.y + camera.y - a.y - a.h/2

	grid_x1 = map.grid_at_pos(math.min(a.x, a.x + vx))
	grid_x2 = map.grid_at_pos(math.max(a.x + a.w, a.x + vx + a.w))
	grid_y1 = map.grid_at_pos(math.min(a.y, a.y + vy))
	grid_y2 = map.grid_at_pos(math.max(a.y + a.h, a.y + vy + a.h))

	mx, my, mt, mnx, mny = a.x + vx, a.y + vy, 1, 0, 0

	for i = grid_x1, grid_x2 do
		for j = grid_y1, grid_y2 do
			if mainmap:grid_has_collision(i, j) then
				block_type = mainmap:block_at(i, j)
				box = map.bounding_box(i, j)

				if block_data[block_type].slope then
					ijhx, ijhy, ijht, ijnx, ijny = physics.collision_aabb_sweep_slope(a, box, block_data[block_type].slope,
																					  block_data[block_type].slope_y_offset, vx, vy)
				else
					ijhx, ijhy, ijht, ijnx, ijny = physics.collision_aabb_sweep(a, box, vx, vy)
				end

				if ijht and ijht < mt then
					mt = hit_time
					mx = ijhx
					my = ijhy
					mnx = nx
					mny = ny
					if mnx > 0 then
							mx = math.ceil(mx)
						elseif nx < 0 then
							mx = math.floor(mx)
						end
						if mny > 0 then
							my = math.ceil(my)
						elseif ny < 0 then
							my = math.floor(my)
						end
				end
			end
		end
	end

	if mt < 1 then
		rt = 1 - mt
		-- px = ny
		-- py = -nx
		-- wx = vx * rem_time
		-- wy = vy * rem_time

		-- (vx rt, vy rt) dot (ny, -nx)
		r = vx * rt * mny - vy * rt * mnx

		rvx = r * mny
		rvy = r * (-mnx)
	end

	-- draw debug tracer
	if mt == 1 then
		love.graphics.setColor(100, 200, 150)
	else
		love.graphics.setColor(200, 200, 50)
	end
	love.graphics.line(a.x + a.w/2 - camera.x, a.y + a.h/2 - camera.y, mx + a.w/2 - camera.x, my + a.h/2 - camera.y)
	love.graphics.rectangle('line', mx - camera.x, my - camera.y, a.w, a.h)
	love.graphics.setColor(color.white)
	-- love.graphics.rectangle('line', a.x - camera.x, a.y - camera.y, a.w, a.h)
	if mt < 1 then
		love.graphics.line(mx + a.w/2 - camera.x, my + a.h/2 - camera.y, mx + a.w/2 - camera.x + mnx * 8, my + a.h/2 - camera.y + mny * 8)
		love.graphics.line(mx + a.w/2 - camera.x, my + a.h/2 - camera.y, mx + a.w/2 - camera.x + rvx, my + a.h/2 - camera.y + rvy)
	end
end

return physics
