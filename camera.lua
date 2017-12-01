local camera = { x=0, y=0, rx=0, ry=0, tx=0, ty=0 }

function camera.update(dt)
	-- lerp the camera
	if controller:getActiveDevice() == "joystick" then
		camera.tx = player.x + player.w/2 - window.w/2
		camera.ty = math.min(player.y + player.h/2 - window.h/2, mainmap.death_line - 64 - window.h)
	else
		camera.tx = player.x + player.w/2 - 1.3 * window.w/2 + 0.3 * mouse.x
		camera.ty = math.min(player.y + player.h/2 - 1.3 * window.h/2 + 0.3 * mouse.y, mainmap.death_line - 64 - window.h)
	end
	camera.rx = camera.rx - (camera.rx - camera.tx) * dt * 7
	camera.ry = camera.ry - (camera.ry - camera.ty) * dt * 7

	camera.x, camera.y = math.floor(camera.rx), math.floor(camera.ry)
end

-- #verifyvenuz
function camera.shake(v, angle)
	angle = angle or love.math.random() * 2 * math.pi
	camera.rx = camera.rx + v * math.cos(angle)
	camera.ry = camera.ry + v * math.sin(angle)
end

return camera
