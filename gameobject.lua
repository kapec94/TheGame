local GameObject = class {
	init = function (self, x, y)
		self.pos = vec(x or 0, y or 0)
	end;
	
	getPos = function (self)
		return self.pos
	end;

	getXY = function (self)
		return self.pos.x, self.pos.y
	end;
}

return GameObject
