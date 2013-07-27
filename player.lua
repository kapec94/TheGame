-- wow, now that's obsfucated function, ain't it.
-- pos - current object position in given dimention
-- dr - moving offset
-- collision_fn - boolean function checking if there's a collision going
-- object_size - object's size in given dimention
-- tile_size - tile's size in given dimention
-- RETURN VALUE: <bool indicating if there is a collision to resolve>, <resolved position>
local function resolve_collision(pos, dr, object_size, tile_size, collision_fn)
	local function clamp(val)
		if math.abs(val) > 1 then
			return math.abs(val) / val
		else
			return val
		end
	end

	local t = 1
	local s = object_size / 2
	local round = math.floor
	if dr < 0 then
		dr = math.abs(dr)
		t = -t
		s = -s
		round = math.ceil
	end
	while dr ~= 0 do
		local newpos = pos + clamp(dr) * t * tile_size
		if collision_fn(newpos + s) then
			return true, round((newpos + s) / tile_size) * tile_size - s
		else
			pos = newpos
			dr = dr - math.abs(t)
			if dr < 0 then dr = 0 end
		end
	end
	return false, pos
end;

local Player = class {
	__includes = GameObject;

	Width = 20;
	Height = 20;
	Color = Colors.blue;

	init = function (self, x, y)
		self.id = Game:registerObject(self)
		self.pos = vec(x, y)
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
		local x, y = self.pos.x, self.pos.y
		local w, h = self.Width / 2, self.Height / 2

		-- Gravity first of all.
		if map:sample(x - w, y + h) == nil and map:sample(x + w - 1, y + h) == nil then
			self.v = self.v + Config.Gravity * dt
			self.falling = true
		end

		self.v.x = (self.moveleft and -150 or 0) + (self.moveright and 150 or 0)

		-- I hate this part, but it has to be done.	
		local x_collision, x = resolve_collision(
			x, self.v.x * dt / Tile.Width, 
			self.Width, Tile.Width,
			function (pos) return map:sample(pos, y) ~= nil end)
		local y_collision, y = resolve_collision(
			y, self.v.y * dt / Tile.Height,
			self.Height, Tile.Height,
			function (pos) return map:sample(x, pos) ~= nil end)

		if x_collision == true then self.v.x = 0 end
		if y_collision == true then 
			self.v.y = 0 
			self.falling = false
		end

		self.pos.x = x
		self.pos.y = y
	end;
}

return Player
