map = {
	height = 48,
	width = 80,
	walls = {{07,04},{07,05},{07,06},{07,07},{08,07},{09,07},},
}

function init_map() -- populates the map with 0 and 1
	for i=1, map.height do -- first all turns 0
		map[i] = {}
		for j=1, map.width do
			map[i][j] = 0
		end
	end

	for i=1, #map.walls do -- then add walls
		map[map.walls[i][2]][map.walls[i][1]] = 1
	end
end
