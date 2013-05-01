local Player = class {
	__includes = GameObject;

	Width = 30;
	Height = 30;
	Color = Colors.cornflowerBlue;

	init = function (self, x, y)
		GameObject.init(self, x, y)
		self.v = vec(0, 0)
		self.falling = true
		self.shape = shapes.newRectangleShape(self.pos.x, self.pos.y, self.Width, self.Height)
	end;

	getShape = function (self)
		return self.shape
	end;

	onDraw = function (self)
		love.graphics.setColor(self.Color)
		love.graphics.rectangle("fill", self.pos.x - self.Width / 2, self.pos.y - self.Height / 2,
			self.Width, self.Height)
	end;

	onKeyPress = function (self, key)
		if key == 'left' then
			self.v.x = -150
		end
		if key == 'right' then
			self.v.x = 150
		end
		if key == ' ' then
			self.v.y = -math.sqrt(2 * 4 * Config.Gravity.y * self.Height)
		end
	end;

	onKeyRelease = function (self, key)
		if key == 'left' or key == 'right' then
			self.v.x = 0
		end
	end;

	move = function (self, dr)
		self.pos = self.pos + dr
		self.shape:move(dr.x, dr.y)
	end;

	onUpdate = function (self, dt)
		self.v = self.v + Config.Gravity * dt
		self:move(self.v * dt)
	end;

	onCollision = function (self, dt, shape, dx, dy)
		self:move(vec(dx, dy))

		-- I don't know, why. Don't ask me.                                                                              ?
		if shape:intersectsRay(self.pos.x - self.Width / 2 + 1, self.pos.y + self.Height / 2, self.Width, self.Height * 1.6) then
			self.v.y = 0
		end
		if shape:intersectsRay(self.pos.x, self.pos.y, 0, -self.Height) then
			self.v.y = 0
		end
	end;
}

return Player
