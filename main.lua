 --[[ Cave Boy http://github.com/qubodup/cave-boy/
]]--
function load()

	love.filesystem.require("map.lua")

	color = { -- color table
		light =		love.graphics.newColor(044,044,044), -- background
		dark =		love.graphics.newColor(011,011,011), -- walls
		blue =		love.graphics.newColor(015,072,255), -- cave boy!
		green =		love.graphics.newColor(016,167,042), -- secret!
		orange =	love.graphics.newColor(243,065,015), -- exit!
	}

	love.graphics.setBackgroundColor(color.light) -- set background color

	boy = {
		x = 2,
		y = 2, 
		color = color.blue
	}
	secret = {
		x = 10,
		y = 30,
		color = color.green
	}
	exit = { -- 
		x = 40,
		y = 20,
		color = color.orange
	}
	wall = {
		color = color.dark
	}

	tilesize = 16 -- the pixel width and height of a tile

	screen = { -- screen size to make the game somewhat independant from window size
		x = love.graphics.getWidth(),
		y = love.graphics.getHeight(),
	}

	key_down = { -- tracks pressed key
		up = false,
		right = false,
		down = false,
		left = false,
		duration = 0, -- for how long has a key been pressed?
	}
	
	init_map() -- fills map with zeroes and ones

end

function update(dt)
	if key_down.up or key_down.right or key_down.down or key_down_left then
	
	else
		key_down.duration = 0
	end
	if key_down.up then try_move_boy("up")
	elseif key_down.right then try_move_boy("right")
	elseif key_down.down then try_move_boy("down")
	elseif key_down.left then try_move_boy("left")
	end
end

function draw()
	love.graphics.setColor(boy.color) -- boy color
	love.graphics.rectangle(0,(boy.x-1)*tilesize,(boy.y-1)*tilesize,tilesize,tilesize) -- boy draw
	love.graphics.setColor(secret.color) -- boy color
	love.graphics.rectangle(0,(secret.x-1)*tilesize,(secret.y-1)*tilesize,tilesize,tilesize) -- boy draw
	love.graphics.setColor(exit.color) -- boy color
	love.graphics.rectangle(0,(exit.x-1)*tilesize,(exit.y-1)*tilesize,tilesize,tilesize) -- boy draw
end

function keypressed(key)
		if key == love.key_up		then key_down.up = true
	elseif key == love.key_right	then key_down.right = true
	elseif key == love.key_down		then key_down.down = true
	elseif key == love.key_left		then key_down.left = true
	elseif key == love.key_escape	then love.system.exit() -- shutting down
	end
end

function keyreleased(key)
	if key == love.key_up			then key_down.up = false
	elseif key == love.key_right	then key_down.right = false
	elseif key == love.key_down		then key_down.down = false
	elseif key == love.key_left		then key_down.left = false
	end
end

function try_move_boy(direction) -- checks if movement is possible, if yes, moves

	local to = { -- table that stores what coordinates boy *would* move to, if he can
		x = boy.x, -- if x is not affected by direction, it will stay the way it was
		y = boy.y, -- same for y
	}
	-- the next tile in whatever direction the movement is going will be found out
	if direction == "up" then
		if boy.y == 1 then to.y = map.height
		else to.y = boy.y-1 end
	elseif direction == "down" then
		if boy.y == map.height then to.y = 1
		else to.y = boy.y+1 end
	elseif direction == "right" then
		if boy.x == map.width then to.x = 1
		else to.x = to.x+1 end
	elseif direction == "left" then
		if boy.x == 1 then to.x = map.width
		else to.x = to.x-1 end
	end
	if check_tile(to) == true then move_boy(to) else play_bump() end
end

function check_tile(to) -- checks if tile can be accessed
	if map[to.y][to.x] == 0 then
		return true
	else
		return false
	end
end

function play_bump() -- plays a 'walk in the wall' sound
	print("BUMP!")
end

function move_boy(to) -- moves boy to coordinates
	boy.x = to.x
	boy.y = to.y
end
