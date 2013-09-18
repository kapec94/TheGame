local cam = require 'hump.camera'

function Camera(player)
	local c = cam(player.x, player.y)

	c.name = 'Camera'
	c.onUpdate = function (self, dt)
		local x, y = player.x, player.y
		local screen = {
			w = love.graphics.getWidth(),
			h = love.graphics.getHeight()
		}
		local map = Game.map
		local mw, mh = map.width * map.tileWidth, map.height * map.tileHeight

		local dx, dy = 0, 0

		if x + screen.w / 2 < mw and x - screen.w  / 2 > 0 then
			dx = x - self.x
		end

		if y + screen.h / 2 < mh and y - screen.h / 2 > 0 then
			dy = y - self.y
		end

		if dx ~= 0 or dy ~= 0 then
			if self.tween_handle then
				Game.timer:cancel(self.tween_handle)
			end
			self.tween_handle = Game.timer:tween(0.2, self, { x = self.x + dx, y = self.y + dy }, 'out-sine')
		end
	end

	Game:registerObject(c)
	return c
end

