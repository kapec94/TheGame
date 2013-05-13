local Player = class {
	__includes = GameObject;

	Width = 20;
	Height = 20;
	Color = Colors.blue;

	init = function (self, x, y)
		GameObject.init(self, x, y)
		self.v = vec(0, 0)
		self.falling = true
		self.moveleft = false
		self.moveright = false
	end;

	onDraw = function (self)
		love.graphics.setColor(self.Color)
		love.graphics.rectangle("fill", self.pos.x - self.Width / 2, self.pos.y - self.Height / 2,
			self.Width, self.Height)
	end;

	onKeyPress = function (self, key)
		if key == 'left' then
			self.moveleft = true
		end
		if key == 'right' then
			self.moveright = true
		end
		if key == ' ' then
			if not self.falling then
				self.v.y = -math.sqrt(2 * 4 * Config.Gravity.y * self.Height)
			end
		end
	end;

	onKeyRelease = function (self, key)
		if key == 'left' and self.moveleft == true then
			self.moveleft = false
		end
		if key == 'right' and self.moveright == true then
			self.moveright = false
		end
	end;

	move = function (self, dr)
		self.pos = self.pos + dr
		self.shape:move(dr.x, dr.y)
	end;

	onUpdate = function (self, dt)
		local map = Game.map
		local x, y = 
			(self.pos.x / Tile.Width), 
			(self.pos.y / Tile.Height)

		local w, h = 
			(self.Width / 2) / Tile.Width,
			(self.Height / 2) / Tile.Height

		-- one tile. You'll understand.
		local t = 1

		-- Gravity first of all.
		if map.tiles(math.floor(x - w), math.floor(y + h)) == nil
		and map.tiles(math.floor(x + w), math.floor(y + h)) == nil then
			self.v = self.v + Config.Gravity * dt
			self.falling = true
		end

		self.v.x = (self.moveleft and -150 or 0) + (self.moveright and 150 or 0)
		
		-- VERTICAL MOVEMENT
		local dr = self.v.y * dt / Tile.Height
		if dr < 0 then
			dr = math.abs(dr)
			h = -h
			t = -t
		end
		while dr ~= 0 do
			-- There's still more than one tile to go through
			if dr > math.abs(t) then
				local nx, ny = math.floor(x), math.floor(y + h + t)
				if map.tiles(nx, ny) ~= nil then
					self.v.y = 0
					self.falling = false
					y = ny - h
					dr = 0
				else
					y = y + t
					dr = dr - math.abs(t)
				end
			else
				local nx, ny = math.floor(x), math.floor(y + h + dr)
				if map.tiles(nx, ny) ~= nil then
					self.v.y = 0
					self.falling = false
					y = ny - h
				else
					-- May cause undefined behaviour when math.abs(t) ~= 1
					y = y + dr * t
				end
				dr = 0
			end
		end

		-- HORIZONTAL MOVEMENT
		t = 1
		dr = self.v.x * dt / Tile.Width
		
		if dr < 0 then
			dr = math.abs(dr)
			t = -t
			w = -w
		end
		while dr ~= 0 do
			-- There's still more than one tile to go through
			if dr > math.abs(t) then
				local nx, ny = math.floor(x + w + t), math.floor(y)
				if map.tiles(nx, ny) ~= nil then
					self.v.x = 0
					x = nx - w
					dr = 0
				else
					x = x + t
					dr = dr - math.abs(t)
				end
			else
				local nx, ny = math.floor(x + h + dr), math.floor(y)
				if map.tiles(nx, ny) ~= nil then
					self.v.x = 0
					x = nx - w
				else
					-- May cause undefined behaviour when math.abs(t) ~= 1
					x = x + dr * t
				end
				dr = 0
			end
		end
		
		self.pos.x = x * Tile.Width
		self.pos.y = y * Tile.Height
	end;
}

return Player
