img = {tile = {}}

function img.setup()
	img.cursor = love.graphics.newImage("art/cursor.png")

	img.tile_size = 32

	img.tileset = love.graphics.newImage("art/tileset.png")
	img.tileset:setFilter("nearest", "linear")

	img.nq("void",				 0,	 0)
	img.nq("air",				 1,	 0)
	img.nq("wall",				 2,	 0)
	img.nq("wall",				 3,	 0)
	img.nq("wall",				 4,	 0)
	img.nq("slope_45",			 5,	 0)
	img.nq("slope_-45",			 6,	 0)
	img.nq("slope_45_a",		 7,	 0)
	img.nq("slope_45_b",		 8,	 0)
	img.nq("slope_-45_a",		 9,	 0)
	img.nq("slope_-45_b",		10,	 0)
	img.nq("slope_23_a",		11,	 0)
	img.nq("slope_23_b",		12,	 0)
	img.nq("slope_-23_a",		13,	 0)
	img.nq("slope_-23_b",		14,	 0)

	img.nq_sprite("player", 	 0,	 1)
	img.nq_sprite("demon",		 0,	 3)

	img.nq("dashburst",			 0,	 5)
	img.nq("dashburst",			 1,	 5)
	img.nq("dashburst",			 2,	 5)
	img.nq("dashburst",			 3,	 5)

	img.nq("jumpburst",			 4,	 5)
	img.nq("jumpburst",			 5,	 5)
	img.nq("jumpburst",			 6,	 5)
	img.nq("jumpburst",			 7,	 5)

	img.nq("tripop",			 0,	 6)
	img.nq("tripop",			 1,	 6)
	img.nq("tripop",			 2,	 6)
	img.nq("tripop",			 3,	 6)

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
				img.tileset_batch:add(img.tile[mainmap:block_at(new_x+x, new_y+y)][mainmap:tileframe_at(new_x+x, new_y+y)],
									  x*img.tile_size, y*img.tile_size)
			end
		end
		img.tileset_batch:flush()
		tileset_batch_old_x, tileset_batch_old_y = new_x, new_y
		redraw = false
	end
end

return img
