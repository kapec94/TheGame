local cam = require 'hump.camera'

function Camera(player)
	local c = cam(player:getXY())

	function c:onUpdate (dt)
		self:lookAt(player:getXY())
	end

	return c
end

return Camera
