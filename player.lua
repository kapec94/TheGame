Player = GameObject:subclass("Player")

Player.Width = 30
Player.Height = 30
Player.Color = Colors.cornflowerBlue

function Player:init(x, y)
	self.super:init(x, y)
	self.v = vec(0, 0)
end

function Player:onDraw()
	love.graphics.setColor(self.Color)
	love.graphics.rectangle("fill", self.pos.x - self.Width / 2, self.pos.y - self.Height / 2,
		self.Width, self.Height)
end

function Player:onKeyPress(key)
	if key == 'left' then
		self.v.x = -100
	end
	if key == 'right' then
		self.v.x = 100
	end
end

function Player:onKeyRelease(key)
	if key == 'left' or key == 'right' then
		self.v.x = 0
	end
end

function Player:move(dr)
	self.pos = self.pos + dr
end

function Player:onUpdate(dt)
	self:move(self.v * dt)
end

