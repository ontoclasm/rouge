local audio = {sfx = {}}

function audio.setup()
	audio.sfx.gunfire1 = love.audio.newSource("sfx/gunfire1.wav", static)
	audio.sfx.gunfire1:setVolume(0.5)
	audio.sfx.gunfire2 = love.audio.newSource("sfx/gunfire2.wav", static)
	audio.sfx.land = love.audio.newSource("sfx/land.wav", static)
	audio.sfx.dash = love.audio.newSource("sfx/dash.wav", static)
	audio.sfx.hit1 = love.audio.newSource("sfx/hit1.wav", static)
	audio.sfx.hit2 = love.audio.newSource("sfx/hit2.wav", static)
	audio.sfx.explosion = love.audio.newSource("sfx/explosion.wav", static)
end

function audio.play(sfx)
	if audio.sfx[sfx] then
		audio.sfx[sfx]:rewind()
		audio.sfx[sfx]:play()
	end
end

return audio
