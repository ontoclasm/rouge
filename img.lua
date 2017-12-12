img = {tile = {}}

function img.setup()
	img.cursor = love.graphics.newImage("art/cursor.png")

	img.tile_size = 32

	img.tileset = love.graphics.newImage("art/tileset.png")
	img.tileset:setFilter("nearest", "linear")

	img.nq("void",				 0,	 0)
	img.nq("air",				 1,	 0)

	img.nq("backdrop",			 2,	 0)
	img.nq("backdrop",			 3,	 0)
	img.nq("backdrop",			 4,	 0)
	img.nq("backdrop",			 5,	 0)

	img.nq_break_block("wall",			 0,  1)
	img.nq_break_block("slope_45",		 3,  1)
	img.nq_break_block("slope_-45",		 6,  1)
	img.nq_break_block("slope_45_a",	 9,  1)
	img.nq_break_block("slope_45_b",	12,  1)
	img.nq_break_block("slope_-45_a",	 0,  2)
	img.nq_break_block("slope_-45_b",	 3,  2)
	img.nq_break_block("slope_23_a",	 6,  2)
	img.nq_break_block("slope_23_b",	 9,  2)
	img.nq_break_block("slope_-23_a",	12,  2)
	img.nq_break_block("slope_-23_b",	 0,  3)

	img.nq_sprite("player", 	 0,	 4)
	img.nq_sprite("demon",		 0,	 6)

	img.nq("dashburst",			 0,	 8)
	img.nq("dashburst",			 1,	 8)
	img.nq("dashburst",			 2,	 8)
	img.nq("dashburst",			 3,	 8)

	img.nq("jumpburst",			 4,	 8)
	img.nq("jumpburst",			 5,	 8)
	img.nq("jumpburst",			 6,	 8)
	img.nq("jumpburst",			 7,	 8)

	img.nq("tripop",			 0,	 9)
	img.nq("tripop",			 1,	 9)
	img.nq("tripop",			 2,	 9)
	img.nq("tripop",			 3,	 9)

	img.nq("bullet_0",			 0,	10)
	img.nq("bullet_23",			 1,	10)
	img.nq("bullet_45",			 2,	10)

	img.nq("plasma_0",			 3,	10)
	img.nq("plasma_23",			 4,	10)
	img.nq("plasma_45",			 5,	10)

	img.nq("c4_0",				 6,	10)
	img.nq("c4_23",				 7,	10)
	img.nq("c4_45",				 8,	10)

	img.nq("missile_0",			 9,	10)
	img.nq("missile_23",		10,	10)
	img.nq("missile_45",		11,	10)

	img.nq("spark_s",				 0,	11)
	img.nq("spark_m",				 1,	11)
	img.nq("spark_l",				 2,	11)
	img.nq("chunk_s",				 3,	11)
	img.nq("chunk_m",				 4,	11)

	img.tile["explosion"] = {n = 2}
	img.tile["explosion"][1] = love.graphics.newQuad(0, 448, 64, 64, img.tileset:getWidth(), img.tileset:getHeight())
	img.tile["explosion"][2] = love.graphics.newQuad(64, 448, 64, 64, img.tileset:getWidth(), img.tileset:getHeight())

	img.view_tilewidth = math.ceil(window.w / img.tile_size)
	img.view_tileheight = math.ceil(window.h / img.tile_size)

	img.tileset_batch = love.graphics.newSpriteBatch(img.tileset, (img.view_tilewidth+1)*(img.view_tileheight+1))
	img.update_tileset_batch()
end

function img.nq(name, x, y)
	if not img.tile[name] then
		img.tile[name] = {n = 1}
	else
		img.tile[name].n = img.tile[name].n + 1
	end

	img.tile[name][img.tile[name].n] = love.graphics.newQuad(x * img.tile_size, y * img.tile_size, img.tile_size, img.tile_size,
										img.tileset:getWidth(), img.tileset:getHeight())
end

function img.nq_break_block(name, x, y)
	for i=0, 3 do
		img.nq(name, x+i, y)
	end
end

function img.nq_sprite(name, x, y)
	for j=0, 1 do
		if j == 0 then
			f = 'r'
		else
			f = 'l'
		end

		img.nq(name .. 'id' .. f, 	x,   y+j) -- idle

		img.nq(name .. 'wr' .. f, 	x+1, y+j) -- walk right
		img.nq(name .. 'wr' .. f, 	x+2, y+j)

		img.nq(name .. 'wl' .. f, 	x+3, y+j) -- walk left
		img.nq(name .. 'wl' .. f, 	x+4, y+j)

		img.nq(name .. 'dr' .. f, 	x+5, y+j) -- dash right

		img.nq(name .. 'dl' .. f, 	x+6, y+j) -- dash left

		img.nq(name .. 'au' .. f, 	x+7, y+j) -- air up

		img.nq(name .. 'ad' .. f, 	x+8, y+j) -- air down
	end
end

local tileset_batch_old_x = nil
local tileset_batch_old_y = nil
redraw = false
function img.update_tileset_batch()
	new_x, new_y = math.floor(camera.x/img.tile_size), math.floor(camera.y/img.tile_size)
	if new_x ~= tileset_batch_old_x or new_y ~= tileset_batch_old_y or redraw == true then
		img.tileset_batch:clear()
		for x=0, img.view_tilewidth do
			for y=0, img.view_tileheight do
				if not block_data[mainmap:block_at(new_x+x, new_y+y)].invisible then
					img.tileset_batch:add(img.tile[mainmap:block_at(new_x+x, new_y+y)][mainmap:tileframe_at(new_x+x, new_y+y)],
										  x*img.tile_size, y*img.tile_size)
				end
			end
		end
		img.tileset_batch:flush()
		tileset_batch_old_x, tileset_batch_old_y = new_x, new_y
		redraw = false
	end
end

local rotational_sprite_functions = {
	[0] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_0"][frame],
						   x, y, 0, 1, 1,
						   16, 16)
	end,

	[1] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, 0, 1, 1,
						   16, 16)
	end,

	[2] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_45"][frame],
						   x, y, 0, 1, 1,
						   16, 16)
	end,

	[3] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, math.pi / 2, 1, -1,
						   16, 16)
	end,

	[4] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_0"][frame],
						   x, y, math.pi / 2, 1, 1,
						   16, 16)
	end,

	[5] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, math.pi / 2, 1, 1,
						   16, 16)
	end,

	[6] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_45"][frame],
						   x, y, math.pi / 2, 1, 1,
						   16, 16)
	end,

	[7] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, 0, -1, 1,
						   16, 16)
	end,

	[8] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_0"][frame],
						   x, y, 0, -1, 1,
						   16, 16)
	end,

	[9] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, math.pi, 1, 1,
						   16, 16)
	end,

	[10] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_45"][frame],
						   x, y, math.pi, 1, 1,
						   16, 16)
	end,

	[11] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, math.pi / 2, -1, 1,
						   16, 16)
	end,

	[12] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_0"][frame],
						   x, y, - math.pi / 2, 1, 1,
						   16, 16)
	end,

	[13] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, - math.pi / 2, 1, 1,
						   16, 16)
	end,

	[14] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_45"][frame],
						   x, y, - math.pi / 2, 1, 1,
						   16, 16)
	end,

	[15] = function(name, frame, x, y)
		love.graphics.draw(img.tileset, img.tile[name .. "_23"][frame],
						   x, y, 0, 1, -1,
						   16, 16)
	end
}

function img.draw_rotational_sprite(name, frame, x, y, angle)
	angle = (mymath.round(angle * 8 / math.pi)) % 16 -- remember y+ (i.e. pi/2) is DOWN :suicide:

	rotational_sprite_functions[angle](name, frame, x, y)
end

return img
