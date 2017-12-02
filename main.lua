require "requires"

function love.load()
	guitime = 0
	ctime = 0

	window = {}
	window.w, window.h = 1280, 800
	love.window.setMode(window.w, window.h)
	love.graphics.setBackgroundColor(16, 16, 32)

	shaderDesaturate = love.graphics.newShader("desaturate.lua")

	control_bindings = {
		-- aim controls
		r_left = {'key:left', 'axis:rightx-'},
		r_right = {'key:right', 'axis:rightx+'},
		r_up = {'key:up', 'axis:righty-'},
		r_down = {'key:down', 'axis:righty+'},
		-- movement
		dp_left = {'key:a', 'button:dpleft'},
		dp_right = {'key:d', 'button:dpright'},
		dp_up = {'key:w', 'button:dpup'},
		dp_down = {'key:s', 'button:dpdown'},
		-- buttons
		a = {'key:g', 'button:a'},
		x = {'key:r', 'button:x'},
		y = {'key:t', 'button:y'},
		r1 = {'mouse:1', 'button:rightshoulder'},
		l1 = {'key:space', 'button:leftshoulder'},

		menu = {'key:escape', 'button:start'},
		view = {'key:q', 'button:back'},
	}
	controller = baton.new(control_bindings) -- set controller.joystick to a Joystick later
	controller.pairs = {dpad = {'dp_left', 'dp_right', 'dp_up', 'dp_down'}}
	controller.deadzone = 0.2

	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)
	mouse = {x = love.mouse.getX(), y = love.mouse.getY()}

	font = love.graphics.newImageFont("art/font.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)
	love.graphics.setLineWidth(0)

	game_state = "play"

	mainmap = map:new(48, 32)
	mainmap:fill_main()

	nextpiece = map:new(7,7)
	nextpiece:fill_z()

	img.setup()

	audio.setup()
	love.audio.setVolume(0.3)

	gravity = 2000

	player = actor:new(
		{
			class = "player", id = 1, name = "player1", faction = "player",
			x = 250, y = 250, w = 16, h = 16,
			dx = 0, dy = 0,
			sprite = "player", color = color.rouge, flash_color = color.white, flash_time = 0,
			facing = 'r', anim_start = ctime,
			ai = {control = "player"}, controls = {},
			top_speed = 250,
			walk_accel = 1200, walk_friction = 500,
			jump_speed = 550, air_accel = 700,
			dash_speed = 700, dash_dur = 0.3, dash_cooldown = 0.1,
			touching_floor = false, double_jumps = 0, double_jumps_max = 2,
			hp = 1000, status = {},
			weapon = weapon_data.spawn("default"), weapon2 = weapon_data.spawn("shotgun"),
			shot_cooldown = 0, cof = 0, cof_factor = 0
		})

	enemies = {}
	shots = {}
	sparks = {}

	spawn(3)
end

function love.update(dt)
	guitime = love.timer.getTime()

	-- handle input
	controller:update()
	if game_state == "pause" then
		if controller:pressed('menu') then unpause() end
		if controller:pressed('view') then love.event.push("quit") end
	elseif game_state == "play" then
		if controller:pressed('menu') then pause() end
	end

	if game_state == "play" then
		-- maybe there's a better way to do this
		ctime = ctime + dt

		camera.update(dt)

		-- update everything
		player:update(dt, nil)
		for _,v in pairs(enemies) do
			v:update(dt)
		end

		for _,v in pairs(shots) do
			v:update(dt)
		end

		for _,v in pairs(sparks) do
			v:update(dt)
		end
	end
end

function love.draw()
	if game_state == "pause" then
		love.graphics.setShader(shaderDesaturate)
	end

	img.update_tileset_batch()
	love.graphics.draw(img.tileset_batch, -(camera.x%32), -(camera.y%32))

	for _,v in pairs(enemies) do
		v:draw()
	end

	player:draw()

	for _,v in pairs(shots) do
		v:draw()
	end

	for _,v in pairs(sparks) do
		v:draw()
	end

	-- gui
	love.graphics.setColor(player.weapon.color)
	if player:check_status("reload") then
		love.graphics.arc("line", "open", view_x(player) + player.w/2, view_y(player) + player.h/2, 20, 0,
						  2 * math.pi * (player.status.reload - ctime) / player.weapon.reload_time)
	end

	if game_state == "play" then
		love.graphics.draw(img.cursor, mouse.x - 2, mouse.y - 2)
		love.graphics.circle("line",  mouse.x, mouse.y,
							 math.sin(player.cof) * mymath.dist(mouse.x, mouse.y, view_x(player) + player.w/2, view_y(player) + player.h/2))
	end

	love.graphics.setColor(player.color)
	love.graphics.print(player.hp, 20, 20)
	love.graphics.setColor(color.white)
	love.graphics.print({player.weapon.color,
						"[ " .. player.weapon.name .. " ]\n" .. counter_string(player.weapon.ammo, player.weapon.ammo_glyph),
						color.dkgrey,
						counter_string(player.weapon.ammo_max - player.weapon.ammo, player.weapon.ammo_glyph)},
						20, 40)
	-- debug msg
	love.graphics.line(-camera.x + 32, -camera.y + mainmap.death_line, -camera.x +(mainmap.width+1) * 32, -camera.y + mainmap.death_line)
	love.graphics.print("FPS: "..love.timer.getFPS(), 20, window.h - 120)
	love.graphics.print("d: "..math.floor(player.dx)..", "..math.floor(player.dy), 20, window.h - 100)
	love.graphics.print(player.x..", "..player.y, 20, window.h - 80)
	local dc = love.graphics.getStats()
	love.graphics.print("draws: "..dc.drawcalls, 20, window.h - 60)
	love.graphics.print(map.grid_at_pos(mouse.x + camera.x)..", "..map.grid_at_pos(mouse.y + camera.y), 20, window.h - 40)

	physics.map_collision_test(player)

	if game_state == "pause" then
		love.graphics.setShader()
		draw_pause_menu()
	end
end

function love.keypressed(key, unicode)
	-- if key == "escape" then
	-- 	if game_state == "pause" then unpause()
	-- 	elseif game_state == "play" then pause()
	-- 	end
	-- end

	-- timers
	-- if key == "a" then
	-- 	if (guitime - last_key_dir.l) < doubletap_time and not player:check_status("dash_cooldown") then
	-- 		player:dash_left()
	-- 	end
	-- 	last_key_dir.l = guitime
	-- end
	-- if key == "d" then
	-- 	if (guitime - last_key_dir.r) < doubletap_time and not player:check_status("dash_cooldown") then
	-- 		player:dash_right()
	-- 	end
	-- 	last_key_dir.r = guitime
	-- end
	-- if key == "space" then
	-- 	player.controls.jump = true
	-- 	last_key_dir.u = guitime
	-- end
	-- if key == "s" then
	-- end

	-- if key == "q" then
	-- 	if game_state == "pause" then
	-- 		love.event.push("quit")
	-- 	else
	-- 		player.controls.swap_weapons = true
	-- 	end
	-- end

	-- if key == "r" and player.weapon.ammo ~= player.weapon.ammo_max then
	-- 	player.controls.reload = true
	-- end

	-- debug
	if key == "1" then
		mainmap:print(nextpiece, map.grid_at_pos(mouse.x + camera.x), map.grid_at_pos(mouse.y + camera.y))
	end
	if key == "2" then
		spawn(1)
	end
	if key == "3" then
		mainmap:set_block("slope_45", map.grid_at_pos(mouse.x + camera.x), map.grid_at_pos(mouse.y + camera.y))
	end
	if key == "8" then
		player.dy = player.dy - 50000
	end
	if key == "9" then
		player.dx = player.dx - 50000
	end
	if key == "0" then
		player.dx = player.dx + 50000
		player.dy = player.dy - 50000
	end
end

function love.joystickadded(joystick)
	controller.joystick = joystick
end

function love.focus(f)
	if f then
		love.mouse.setVisible(false)
		love.mouse.setGrabbed(true)
	else
		if game_state ~= "pause" then pause() end
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
end

function spawn(n)
	for i = 1, n do
		enemy_data.spawn("bird", love.math.random(64, mainmap.width*32 - 64),
					love.math.random(64, mainmap.height*32 - 64), 'r')
		enemy_data.spawn("demon", love.math.random(64, mainmap.width*32 - 64),
			love.math.random(64, mainmap.height*32 - 64), 'r')
	end
end

function counter_string(n, glyph)
	if n == 0 then return "" end
	glyph = glyph or "/"
	return string.rep(glyph, n)
end

local pause_mouse_x, pause_mouse_y

function pause()
	game_state = "pause"
	pause_mouse_x, pause_mouse_y = love.mouse.getPosition()
end

function unpause()
	game_state = "play"
	love.mouse.setPosition(pause_mouse_x, pause_mouse_y)
end

function draw_pause_menu()
	love.graphics.setColor(color.rouge)
	love.graphics.circle("fill", window.w/2, window.h/2, 200)
	love.graphics.setColor(color.white)
	love.graphics.printf("Press Q to quit", math.floor(window.w/2 - 200), math.floor(window.h/2 - font:getHeight()/2), 400, "center")
	love.graphics.setColor(color.white)
	love.graphics.draw(img.cursor, love.mouse.getX() - 2, love.mouse.getY() - 2)
end

function view_x(a) return math.floor(a.x-camera.x) end
function view_y(a) return math.floor(a.y-camera.y) end