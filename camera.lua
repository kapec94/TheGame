local cam = require 'hump.camera'

function Camera(player)
	local c = cam(player:getXY())
	c.player = player

	function c:onUpdate (dt)
		self:lookAt(self.player:getXY())
	end

	return c
end

return Camera
