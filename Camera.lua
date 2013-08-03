local cam = require 'hump.camera'

function Camera(player)
	local c = cam(vec.unpack(player.pos))
	Game:registerObject(c)

	c.onUpdate = function (self, dt)
		local x, y = vec.unpack(player.pos)
		local cx, cy = self:pos()
		local map = Game.map
		local mw, mh = map.width * map.tileWidth, map.height * map.tileHeight

		if x + Config.Screen.Width / 2 < mw and x - Config.Screen.Width / 2 > 0 then
			self:move(x - cx, 0)
		end

		if y + Config.Screen.Height / 2 < mh and y - Config.Screen.Height / 2 > 0 then
			self:move(0, y - cy)
		end
	end

	return c
end

