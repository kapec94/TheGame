GameObject = newclass("GameObject")

function GameObject:init(x, y)
	self.pos = vec(x or 0, y or 0)
end

function GameObject:getPos()
	return self.pos
end

function GameObject:getXY()
	return self.pos.x, self.pos.y
end
