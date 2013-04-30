Player = GameObject:subclass("Player")

Player.Width = 30
Player.Height = 30
Player.Color = Colors.cornflowerBlue

function Player:init(x, y)
	self.super:init(x, y)
	
	self.vx = 0
	self.vy = 0
end

function Player:onDraw()
	love.graphics.setColor(self.Color)
	love.graphics.rectangle("fill", self.x, self.y,
		self.Width, self.Height)
end

function Player:onKeyPress(key)
	if key == 'left' then	
		self.vx = -100
	end
	if key == 'right' then
		self.vx = 100
	end
	if key == 'down' then
		self.vy = 100
	end
	if key == 'up' then 
		self.vy = -100
	end
end

function Player:onKeyRelease(key)
	if key == 'left' or key == 'right' then
		self.vx = 0
	elseif key == 'up' or key == 'down' then
		self.vy = 0
	end
end

function Player:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Player:onUpdate(dt)
	self:move(self.vx * dt, self.vy * dt)
end
