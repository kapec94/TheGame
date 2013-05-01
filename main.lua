-- This is the Game.

vec = require "hump.vector"
hc = require "HardonCollider"
shapes = require "HardonCollider.shapes"

require "util"
require "settings"
require "colors"

require "YaciCode"

require "gameobject"
require "map"
require "player"
require "game"

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)

	map = Map("test")
	Game:setMap(map)
	Game:addDrawable(map)
	
	me = Player(50, 50)
	Game:addActive(me)
	Game:addInteractive(me)
	Game:addDrawable(me)
	Game:addCollidable(me, true)

	local map_data = {
		0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
		1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
		1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0,
		1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	}
	for y = 0, map.Height - 1 do
		for x = 0, map.Width - 1 do
			map:setTile(x, y, map_data[y * map.Width + x + 1] == 1)
		end
	end
	util.mmap (function (t) Game:addCollidable(t, false) end, map:getFilledTiles())
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
	Game.collider:update(dt)
end

function love.draw()
	for _, d in ipairs(Game.drawables) do
		util.mmap(function (v) v:onDraw() end, d)
	end
end

function on_collision(dt, shape_a, shape_b, dx, dy)
	local obj_a = Game.shapes[shape_a]
	local obj_b = Game.shapes[shape_b]

	if obj_a.onCollision then obj_a:onCollision(dt, shape_b, dx, dy) end
	if obj_b.onCollision then obj_b:onCollision(dt, shape_a, -dx, -dy) end
end

function on_collision_end(dt, shape_a, shape_b, dx, dy)
	local obj_a = Game.shapes[shape_a]
	local obj_b = Game.shapes[shape_b]

	if obj_a.onCollisionEnd then obj_a:onCollisionEnd(dt, shape_b, dx, dy) end
	if obj_b.onCollisionEnd then obj_b:onCollisionEnd(dt, shape_a, -dx, -dy) end
end

function love.quit()
	love.event.quit()
end

love.run()
