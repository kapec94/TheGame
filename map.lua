Map = newclass("Map")

Map.Width = 12
Map.Height = 9

function Map:init(name)
	self.name = name
	self.tiles = {}
	for x = 0, self.Width - 1 do
		for y = 0, self.Height - 1 do
			local i = y * self.Width + x
			self.tiles[i] = Tile:new(false, 
				x * Tile.static.Width + Tile.static.Width / 2, 
				y * Tile.static.Height + Tile.static.Height / 2)
		end
	end
end

function Map:getTile(x, y)
	return self.tiles[y * self.Width + x]
end

function Map:getFilledTiles()
	return util.select (function (t) return t:isFilled() end, self.tiles)
end

function Map:setTile(x, y, fill)
	self.tiles[y * self.Width + x].filled = fill
end

function Map:sample(x, y)
	return self:getTile(math.floor(x / Tile.static.Width), math.floor(y / Tile.static.Height))
end

function Map:onDraw()
	util.mmap(function (tile) tile:draw() end, self:getFilledTiles())
end

Tile = GameObject:subclass("Tile")

Tile.Color = Colors.white
Tile.Width = Config.Screen.Width / Map.static.Width 
Tile.Height = Config.Screen.Height / Map.static.Height

function Tile:init(fill, x, y)
	self.filled = fill
	self.super:init(x, y)
end

function Tile:getShape()
	return shapes.newRectangleShape(self.pos.x, self.pos.y, self.Width, self.Height)
end

function Tile:isFilled()
	return self.filled
end

function Tile:draw()
	love.graphics.setColor(self.Color)
	love.graphics.rectangle('fill',
		self.pos.x - self.Width / 2, self.pos.y - self.Height / 2,
		self.Width, self.Height)
end
