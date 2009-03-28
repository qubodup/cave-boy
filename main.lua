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
		x = 10,
		y = 20, 
		color = color.blue,
	}
	secret = {
		x = 30,
		y = 40,
		color = color.green,
		collected = false,
	}
	exit = { -- 
		x = 75,
		y = 10,
		color = color.orange,
	}
	wall = {
		color = color.dark,
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

	love.audio.setMode(96000, 2, 1024)

	sfx = { -- sounds table
		ouch = {
			love.audio.newSound("sfx/ouch-01.ogg"),
			love.audio.newSound("sfx/ouch-02.ogg"),
			love.audio.newSound("sfx/ouch-03.ogg"),
			love.audio.newSound("sfx/ouch-04.ogg"),
			love.audio.newSound("sfx/ouch-05.ogg"),
			love.audio.newSound("sfx/ouch-06.ogg"),
			love.audio.newSound("sfx/ouch-07.ogg"),
			love.audio.newSound("sfx/ouch-08.ogg"),
		},
		--secret = love.audio.newSound("sfx/coins.ogg"),
		--exit = love.audio.newSound("sfx/door.ogg"),
		voice = {
			 title = love.audio.newSound("sfx/voice-cave_boy.ogg"),
			 press = love.audio.newSound("sfx/voice-press_arrow.ogg"),
			 move = love.audio.newSound("sfx/voice-move_cave_boy.ogg"),
			 find = love.audio.newSound("sfx/voice-find_secret.ogg"),
			 exit = love.audio.newSound("sfx/voice-go_exit.ogg"),
			 collect = love.audio.newSound("sfx/voice-secret_collect.ogg"),
			 went = love.audio.newSound("sfx/voice-exit_went.ogg"),
		}
	}

	love.audio.play(sfx.voice.title)

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
	if not secret.collected then
		love.graphics.setColor(secret.color) -- secret color
		love.graphics.rectangle(0,(secret.x-1)*tilesize,(secret.y-1)*tilesize,tilesize,tilesize) -- boy draw
	end
	love.graphics.setColor(exit.color) -- exit color
	love.graphics.rectangle(0,(exit.x-1)*tilesize,(exit.y-1)*tilesize,tilesize,tilesize) -- boy draw

	love.graphics.setColor(wall.color)	-- wall color
	for i=1, #map.walls do -- draw walls
		love.graphics.rectangle(0,(map.walls[i][1]-1)*tilesize,(map.walls[i][2]-1)*tilesize,tilesize,tilesize)
	end
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
	if check_tile(to) == true then move_boy(to) else bump() end
end

function check_tile(to) -- checks if tile can be accessed
	if map[to.y][to.x] == 0 then
		return true
	else
		return false
	end
end

function bump(direction) -- plays a 'walk in the wall' sound and some particle effect
	if not love.audio.isPlaying() then
		love.audio.play(sfx.ouch[math.random(1,#sfx.ouch)])
	end
end

function move_boy(to) -- moves boy to coordinates
	boy.x = to.x
	boy.y = to.y
	check_targets(to) -- checks if secret or exit was hit!
end

function check_targets(to)
	if to.x == secret.x and to.y == secret.y and not secret.collected then
		love.audio.play(sfx.voice.collect)
		secret.collected = true
	end
	if to.x == exit.x and to.y == exit.y then
		if not secret.collected and not love.audio.isPlaying() then
			love.audio.play(sfx.voice.find)
		elseif secret.collected then
			love.audio.play(sfx.voice.went)
			love.timer.sleep(1500)
			love.system.exit()
		end
	end
end
