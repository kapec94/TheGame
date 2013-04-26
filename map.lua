Map = newclass("Map")

Map.Width = 12
Map.Height = 12

function Map:init()
	self.tiles = {}
end

function Map:getTile(x, y)
	return self.tiles[y * self.Width + x]
end

function Map:setTile(x, y, tile)
	self.tiles[y * self.Width + x] = tile
	tile.x = x
	tile.y = y
end

function Map:sample(x, y)
	return self:getTile(math.floor(x / Tile.static.Width), math.floor(y / Tile.static.Height))
end

Tile = GameObject:subclass("Tile")

Tile.Color = Colors.white
Tile.Width = Config.Screen.Width / Map.static.Width 
Tile.Height = Config.Screen.Height / Map.static.Height

function Tile:init(fill, x, y)
	self.filled = false
	self.super:init(x, y)
	self:setFill(fill)
end

function Tile:onDraw()
	love.graphics.setColor(self.Color)
	love.graphics.rectangle('fill',
		self.x * self.Width, self.y * self.Height,
		self.Width, self.Height)
end

function Tile:setFill(fill)
	if fill == false and self.filled == true then
		Game:removeDrawable(self)
	elseif fill == true and self.filled == false then
		Game:addDrawable(self)
	end
end