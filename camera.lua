local cam = require 'hump.camera'

function Camera(player)
	local c = cam(vec.unpack(player.pos))
	
	c.id = Game:registerObject(c)

	function c:onUpdate (dt)
		self:lookAt(vec.unpack(player.pos))
	end

	return c
end

return Camera
