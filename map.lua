local atl = require "atl"
atl.Loader.path = Config.MapPath or './'


local Map = class {
	Tile = class {
		__includes = GameObject;

		init = function (self, x, y)
			GameObject.init(self, x, y)
		end;

		getShape = function (self)
			return shapes.newRectangleShape(
				self.pos.x, self.pos.y, self.Width, self.Height)
		end;
	};
	
	init = function (self, name)
		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")
		self.width = self.map.width
		self.height = self.map.height

		Tile.Width = self.map.tileWidth
		Tile.Height = self.map.tileHeight

		self.tiles = {}
		for x, y, tile in self.map('tiles'):iterate() do
			local t = Tile((x + 0.5) * Tile.Width, (y + 0.5) * Tile.Height)
			table.insert (self.tiles, t)
		end

		self.events = {}
		for i, o in ipairs(self.map('events').objects) do
			self.events[o.name] = o
		end
	end;

	getTiles = function (self)
		return self.tiles
	end;

	onDraw = function (self)
		local cam = Game.camera
		local w, h = Config.Screen.Width, Config.Screen.Height
		local x, y = cam:pos()

		self.map:setDrawRange(x - w / 2, y - h / 2, w, h)
		
		love.graphics.setColor(Colors.white)
		self.map:draw()
	end;
}

return Map
