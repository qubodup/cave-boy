map = {
	height = 48,
	width = 80,
}

function init_map() -- populates the map with 0 and 1
	for i=1, map.height do -- first all turns 0
		map[i] = {}
		for j=1, map.width do
			map[i][j] = 0
		end
	end
end
