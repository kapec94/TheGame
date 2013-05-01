local Map = class {
	Width = 12;
	Height = 9;

	init = function (self, name)
		self.name = name
		self.tiles = {}
		for x = 0, self.Width - 1 do
			for y = 0, self.Height - 1 do
				local i = y * self.Width + x
				self.tiles[i] = Tile(false, 
					x * Tile.Width + Tile.Width / 2, 
					y * Tile.Height + Tile.Height / 2)
			end
		end
	end;

	getTile = function (self, x, y)
		return self.tiles[y * self.Width + x]
	end;

	getFilledTiles = function (self)
		return util.select (function (t) return t:isFilled() end, self.tiles)
	end;

	setTile = function (self, x, y, fill)
		self.tiles[y * self.Width + x].filled = fill
	end;

	sample = function (self, x, y)
		return self:getTile(math.floor(x / Tile.static.Width), math.floor(y / Tile.static.Height))
	end;

	onDraw = function (self)
		util.mmap(function (tile) tile:draw() end, self:getFilledTiles())
	end;
}

local Tile = class {
	__includes = GameObject;

	Color 	= Colors.white;
	Width 	= Config.Screen.Width / Map.Width;
	Height 	= Config.Screen.Height / Map.Height;

	init = function (self, fill, x, y)
		GameObject.init(self, x, y)
		self.filled = fill
	end;

	getShape = function (self)
		return shapes.newRectangleShape(self.pos.x, self.pos.y, self.Width, self.Height)
	end;

	isFilled = function (self)
		return self.filled
	end;

	draw = function (self)
		love.graphics.setColor(self.Color)
		love.graphics.rectangle('fill',
			self.pos.x - self.Width / 2, self.pos.y - self.Height / 2,
			self.Width, self.Height)
	end;
}

return function () return  Map, Tile end
