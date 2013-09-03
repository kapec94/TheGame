local cam = require 'hump.camera'

function Camera(player)
	local c = cam(player.x, player.y)
	Game:registerObject(c)

	c.onUpdate = function (self, dt)
		local x, y = player.x, player.y
		local screen = {
			w = love.graphics.getWidth(),
			h = love.graphics.getHeight()
		}
		local cx, cy = self:pos()
		local map = Game.map
		local mw, mh = map.width * map.tileWidth, map.height * map.tileHeight

		if x + screen.w / 2 < mw and x - screen.w  / 2 > 0 then
			self:move(x - cx, 0)
		end

		if y + screen.h / 2 < mh and y - screen.h / 2 > 0 then
			self:move(0, y - cy)
		end
	end

	return c
end

