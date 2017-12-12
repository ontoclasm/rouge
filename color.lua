color = {
		white =		{255,	255,	255},
		rouge =		{220,	 80,	 80},
		actinic =	{110,	 70,	250},
		blue =		{ 60,	 80,	200},
		ltblue =	{150,	200,	250},
		green =		{ 30,	220,	 80},
		yellow =	{220,	200,	 30},
		orange =	{240,	120,	 30},
		dkgrey =	{ 50,	 70,	 70}
}

function color.r(name)
	return color[name][1]
end

function color.g(name)
	return color[name][2]
end

function color.b(name)
	return color[name][3]
end

function color.rgb(name)
	return color[name][1],color[name][2],color[name][3]
end

function color.mix(a, b, t)
	v = 1-t
	return {v*a[1] + t*b[1], v*a[2] + t*b[2], v*a[3] + t*b[3]}
end

return color
