GameObject = newclass("GameObject")

function GameObject:init(x, y)
	self.pos = vec(x or 0, y or 0)
end
