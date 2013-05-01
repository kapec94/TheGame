-- This is the Game.

vec = require "hump.vector"

require "util"
require "settings"
require "colors"

require "YaciCode"

require "gameobject"
require "game"
require "map"
require "player"

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)

	me = Player(50, 50)
	map = Map()

	Game:addActive(me)
	Game:addInteractive(me)
	Game:addDrawable(me)

	Game:addDrawable(map)

	for y = 0, map.Height - 1 do
		for x = 0, map.Width - 1 do
			map:setTile(x, y, y > map.Height / 2)
		end
	end
end

function love.keypressed(key, unicode)
	for _,o in ipairs(Game.keypressHooks) do
		o:onKeyPress(key)
	end
end

function love.keyreleased(key, unicode)
	for _,o in ipairs(Game.keyreleaseHooks) do
		o:onKeyRelease(key)
	end
end

function love.update(dt)
	for _,o in ipairs(Game.actives) do
		o:onUpdate(dt)
	end
end

function love.draw()
	for _, d in ipairs(Game.drawables) do
		util.mmap(function (v) v:onDraw() end, d)
	end
end

function love.quit()
	love.event.quit()
end

love.run()
