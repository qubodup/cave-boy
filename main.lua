 --[[ Cave Boy http://github.com/qubodup/cave-boy/

   Copyright (C) 2009 Iwan Gabovitch

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

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
		x = 39,
		y = 45,
		color = color.green,
		collected = false,
	}
	exit = { --
		x = 71,
		y = 18,
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
		is_down = false, -- whether or not one of the directional keys is being pressed
		step = 0, -- for how many steps has a key been pressed?
		duration = 0, -- for joystick?
	}

	joy_down = {
		up = false,
		right = false,
		down = false,
		left = false,
		is_down = false
	}

	init_map() -- fills map with zeroes and ones

	love.audio.setMode(96000, 2, 1024) -- hopefully doesn't screw up the audio on your system

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

	intro = { -- the intro sequence as a table...
		step = 1, -- whick step of the intro is being played?
	}

end

function play_intro()
	if not love.audio.isPlaying() then
		if intro.step == 1 then -- Cave Boy!
			love.audio.play(sfx.voice.title)
		elseif intro.step == 2 then -- Press Arrow!
			love.audio.play(sfx.voice.press)
		elseif intro.step == 3 then -- Move Cave Boy!
			love.audio.play(sfx.voice.move)
		elseif intro.step == 4 then -- Find Secret!
			love.audio.play(sfx.voice.find)
		elseif intro.step == 5 then -- Go Exit!
			love.audio.play(sfx.voice.exit)
		end
		intro.step = intro.step + 1 -- next step plz!
	end
end

function update(dt)

	joystick_start()

	check_targets(boy) -- checks if boy is on secret or exit

	if intro.step ~= 7 then play_intro() end -- play intro!

	if key_down.is_down or joy_down.is_down then -- timer
		key_down.duration = key_down.duration + dt
	else
		key_down.duration = 0
		key_down.step = 0
	end
	if key_down.step < 2 or (key_down.step > 1 and key_down.duration > .04) or key_down.duration > .2 then -- more than needed I think
		if key_down.up or joy_down.up then try_move_boy("up") -- movement
		elseif key_down.right or joy_down.right then try_move_boy("right")
		elseif key_down.down or joy_down.down then try_move_boy("down")
		elseif key_down.left or joy_down.left then try_move_boy("left")
		end
		key_down.step = key_down.step + 1
		key_down.duration = 0
	end

	joystick_end()

end

function joystick_start()
	if love.joystick.getAxis(0,7) == -1	then joy_down.up = true
	elseif love.joystick.getAxis(0,6) ==  1	then joy_down.right = true
	elseif love.joystick.getAxis(0,7) ==  1	then joy_down.down = true
	elseif love.joystick.getAxis(0,6) == -1	then joy_down.left = true
	end

	if joy == love.joy_up or joy == love.joy_right or joy == love.joy_down or joy == love.joy_left then joy_down.is_down = true end

end

function joystick_end()

	if love.joystick.getAxis(0,7) == 0 then
		joy_down.up = false
		joy_down.down = false
	end
	if love.joystick.getAxis(0,6) == 0 then
		joy_down.right = false
		joy_down.left = false
	end

end

function draw()
	love.graphics.setColor(wall.color)	-- wall color
	for i=1, #map.walls do -- draw walls
		love.graphics.rectangle(0,(map.walls[i][1]-1)*tilesize,(map.walls[i][2]-1)*tilesize,tilesize,tilesize)
	end

	if not secret.collected then
		love.graphics.setColor(secret.color) -- secret color
		love.graphics.rectangle(0,(secret.x-1)*tilesize,(secret.y-1)*tilesize,tilesize,tilesize) -- secret draw
		if intro.step == 5 then draw_cross(secret.x,secret.y) end
	end
	love.graphics.setColor(exit.color) -- exit color
	love.graphics.rectangle(0,(exit.x-1)*tilesize,(exit.y-1)*tilesize,tilesize,tilesize) -- exit draw
	if intro.step == 6 then draw_cross(exit.x,exit.y) end

	love.graphics.setColor(boy.color) -- boy color
	love.graphics.rectangle(0,(boy.x-1)*tilesize,(boy.y-1)*tilesize,tilesize,tilesize) -- boy draw
	if intro.step == 4 then draw_cross(boy.x,boy.y) end

end

function draw_cross(x, y) -- draws a cross around whatever coordinates it gets
	love.graphics.rectangle(0,(x-1)*tilesize+2*tilesize,(y-1)*tilesize,tilesize*3,tilesize)
	love.graphics.rectangle(0,(x-1)*tilesize-4*tilesize,(y-1)*tilesize,tilesize*3,tilesize)
	love.graphics.rectangle(0,(x-1)*tilesize,(y-1)*tilesize+2*tilesize,tilesize,tilesize*3)
	love.graphics.rectangle(0,(x-1)*tilesize,(y-1)*tilesize-4*tilesize,tilesize,tilesize*3)
end

function keypressed(key)
	if key == love.key_up or key == love.key_right or key == love.key_down or key == love.key_left then key_down.is_down = true end
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
	if not key_down.up and not key_down.right and not key_down.down and not key_down.left then key_down.is_down = false end
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

function bump(direction) -- plays a 'walk in the wall' sound
	if not love.audio.isPlaying() then
		love.audio.play(sfx.ouch[math.random(1,#sfx.ouch)])
	end
end

function move_boy(to) -- moves boy to coordinates
	boy.x = to.x
	boy.y = to.y
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

function mousepressed() -- mouse map editor, because this should make it a little easier to make maps...
	local mouse = { -- get mouse coordinates
		x = love.mouse.getX(),
		y = love.mouse.getY(),
	}

	-- convert them to tile coordinates
	local tile = {
		math.floor(mouse.x/tilesize)+1, -- tile's x coordinate
		math.floor(mouse.y/tilesize)+1, -- tile's y coordinate
	}

	map.walls[#map.walls+1] = tile -- add tile to map

	io.write("{"..tile[1]..","..tile[2].."},")-- print results
end
