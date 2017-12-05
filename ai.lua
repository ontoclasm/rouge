local ai = {actions = {}, routines = {}, sequences = {}}

-- enemy ai consists of:
	-- control = "enemy" so actor_update runs it
	-- routines = {} : a priority list, containing functions in priority order (more important first)
		-- these are conditionals like "if the player is within X distance, shoot at her"
		-- each function should first test the condition and return FALSE if it's not met
		-- if the condition is met, react appropriately by setting a.controls, then return TRUE
		-- generally should have a "default" function at the end with no condition
	-- data = {} : a place for routines to store stuff like timers

function ai.setup(a, routine)
	a.ai.routine = ai.routines[routine] -- remember this is pass by ref, not a copy
	a.ai.data = {}

	-- routine-specific setup stuff, e.g. assigning wake_time
	if a.ai.routine.setup then
		a.ai.routine.setup(a)
	end
end

function ai.process(a)
	for i,v in ipairs(a.ai.routine) do
		v(a)
	end

	if a.controls.fire_1 then
		a.controls.aim_x, a.controls.aim_y = player.x, player.y
	end

	-- face forward
	if a.controls.x == 1 then
		a.facing = 'r'
	else
		a.facing = 'l'
	end
end

-- actions

ai.actions["jump"] = function(a) a.controls.jump = true end
ai.actions["dash forward"] = function(a) if a.facing == 'r' then a:dash_right() else a:dash_left() end end
ai.actions["reverse"] = function(a) a.controls.x = a.controls.x * -1 end
ai.actions["start shooting"] = function(a) a.controls.fire_1 = true end
ai.actions["stop shooting"] = function(a) a.controls.fire_1 = false end
ai.actions["change color"] = function(a, r, g, b) a.color = {r, g, b} end
ai.actions["set fly height"] = function(a, y) a.ai.data.fly_height = y end
ai.actions["random direction"] = function(a) if mymath.one_chance_in(2) then a.controls.x = 1 else a.controls.x = -1 end end

ai.actions["bounce off walls"] = function(a)
	if (a.controls.x == 1 and a:is_touching_right()) or (a.controls.x == -1 and a:is_touching_left()) then
		a.controls.x = -a.controls.x
		-- return true
	end
end

ai.actions["bounce off ledges"] = function(a)
	if (a.controls.x == 1 and a:is_on_ledge_right()) or (a.controls.x == -1 and a:is_on_ledge_left()) then
		a.controls.x = -a.controls.x
		-- return true
	end
end

ai.actions["setup fly"] = function(a)
	a.ai.data.fly_timer = 0
	a.ai.data.fly_height = a.y
end

ai.actions["fly"] = function(a)
	-- flap to maintain a height of a.data.fly_height
	-- delay is slightly randomized to make it look sort of ragged
	-- requires a.flies = true or it'll be very stupid
	if ctime > a.ai.data.fly_timer then
		a.controls.jump = true
		local ky = a.y - a.ai.data.fly_height
		if ky > 100 then
			a.ai.data.fly_timer = ctime + 0.15 + love.math.random()/10
		elseif ky < -100 then
			a.ai.data.fly_timer = ctime + 0.35 + love.math.random()/10
		else
			a.ai.data.fly_timer = ctime + 0.25 - ky/1000 + love.math.random()/10
		end
		-- return true
	end
end

local dist
ai.actions["shoot player if close"] = function(a)
	dist = mymath.dist(a.x, a.y, player.x, player.y)
	if dist < 200 then
		ai.actions["start shooting"](a)
	elseif dist > 250 then
		ai.actions["stop shooting"](a)
	end
end

ai.actions["setup sequence"] = function(a)
	a.ai.data.sequence_timer = 0
	a.ai.data.sequence_step = 1
end

local action
ai.actions["run sequence"] = function(a)
	-- run through a sequence of actions
	-- the sequence table needs to be in a.ai.data.sequence
	-- should continue if interrupted; run "setup sequence" to restart
	if ctime >= a.ai.data.sequence_timer then
		action = ai.sequences[a.ai_sequence][a.ai.data.sequence_step]
		if type(action) == "string" then
			-- run a function
			ai.actions[action](a)
		elseif type(action) == "number" then
			-- sleep for N seconds before processing again
			a.ai.data.sequence_timer = a.ai.data.sequence_timer + action
		elseif type(action) == "table" then
			-- run a function w/ params
			ai.actions[action[1]](a, action[2], action[3], action[4])
		end
		a.ai.data.sequence_step = (a.ai.data.sequence_step + 1)
		if a.ai.data.sequence_step > #ai.sequences[a.ai_sequence] then
			a.ai.data.sequence_step = 1
		end
	end
end

ai.sequences["test"] =
{
	{"change color", 100, 200, 0}, 					5,
	"reverse", 										1,
	{"change color", 200, 0, 100}, 					2,
	"jump",											0.3,
	"jump",											2
}

ai.sequences["fly around"] =
{
	{"set fly height", 300, 0, 0},					4,
	{"set fly height", 100, 0, 0},					4,
}

-- routines

ai.routines["flyer"] =
{
	ai.actions["bounce off walls"],
	ai.actions["fly"],
	-- ai.actions["shoot player if close"],
	ai.actions["run sequence"],

	setup = function(a) ai.actions["random direction"](a) ai.actions["setup fly"](a) ai.actions["setup sequence"](a) end,
}

ai.routines["walker"] =
{
	ai.actions["bounce off walls"],
	ai.actions["bounce off ledges"],
	-- ai.actions["shoot player if close"],

	setup = function(a) ai.actions["random direction"](a) end,
}

return ai
