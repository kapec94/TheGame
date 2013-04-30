Map = newclass("Map")

Map.Width = 12
Map.Height = 12

function Map:init()
	self.tiles = {}
	for x = 0, self.Width - 1 do
		for y = 0, self.Height - 1 do
			local i = y * self.Width + x
			self.tiles[i] = Tile:new(false, 
							x * Tile.static.Width, 
							y * Tile.static.Height)
		end
	end
end

function Map:getTile(x, y)
	return self.tiles[y * self.Width + x]
end

function Map:setTile(x, y, fill)
	self.tiles[y * self.Width + x].filled = fill
end

function Map:sample(x, y)
	return self:getTile(math.floor(x / Tile.static.Width), math.floor(y / Tile.static.Height))
end

function Map:onDraw()
	util.imap(function (tile)
		if tile:isFilled() then tile:draw() end
	end, self.tiles)
end

Tile = GameObject:subclass("Tile")

Tile.Color = Colors.white
Tile.Width = Config.Screen.Width / Map.static.Width 
Tile.Height = Config.Screen.Height / Map.static.Height

function Tile:init(fill, x, y)
	self.filled = fill
	self.super:init(x, y)
end

function Tile:isFilled()
	return self.filled
end

function Tile:draw()
	love.graphics.setColor(self.Color)
	love.graphics.rectangle('fill',
		self.pos.x, self.pos.y,
		self.Width, self.Height)
end
