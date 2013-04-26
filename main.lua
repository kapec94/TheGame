-- This is the Game.

require "settings"
require "colors"

require "YaciCode"

require "gameobject"
require "game"
require "map"
require "player"

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)

	me = Player()
	map = Map()

	for y = -1, map.Height do
		for x = -1, map.Width do
			map:setTile(x, y, Tile:new(y > map.Height / 2))
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
	for _,drawable in ipairs(Game.drawables) do
		drawable:onDraw()
	end
end

function love.quit()
	love.event.quit()
end

love.run()
