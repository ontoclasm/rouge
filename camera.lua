local camera = { x=0, y=0, rx=0, ry=0, tx=0, ty=0 }

function camera.update(dt)
	-- lerp the camera
	if controller:getActiveDevice() == "joystick" then
		camera.tx = player.x - window.w/2
		camera.ty = math.min(player.y - window.h/2, mainmap.death_line - 64 - window.h)
	else
		camera.tx = player.x - 1.3 * window.w/2 + 0.3 * mouse.x
		camera.ty = math.min(player.y - 1.3 * window.h/2 + 0.3 * mouse.y, mainmap.death_line - 64 - window.h)
	end

	-- don't move if it's only a 1px adjustment; this avoids irritating little twitches due to rounding error in some cases
	if math.abs(camera.tx - camera.rx) >= 2 then
		camera.rx = camera.rx - (camera.rx - camera.tx) * dt * 7
	end
	if math.abs(camera.ty - camera.ry) >= 2 then
		camera.ry = camera.ry - (camera.ry - camera.ty) * dt * 7
	end

	camera.x, camera.y = math.floor(camera.rx), math.floor(camera.ry)
end

-- #verifyvenuz
function camera.shake(v, angle)
	angle = angle or love.math.random() * 2 * math.pi
	camera.rx = camera.rx + v * math.cos(angle)
	camera.ry = camera.ry + v * math.sin(angle)
end


function camera.view_x(a) return math.floor(a.x - camera.x) end
function camera.view_y(a) return math.floor(a.y - camera.y) end

local vx, vy
function camera.on_screen(a)
	vx = camera.view_x(a)
	vy = camera.view_y(a)
	return vx > -64 and vx < window.w + 64 and vy > -64 and window.h + 64
end

return camera
