local atl = require "atl"
atl.Loader.path = Config.MapPath or './'


local Map = class {
	Tile = class {
		__includes = GameObject;

		init = function (self, x, y)
			GameObject.init(self, x, y)
		end;
	};
	
	init = function (self, name)
		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")
		self.width = self.map.width
		self.height = self.map.height

		Tile.Width = self.map.tileWidth
		Tile.Height = self.map.tileHeight

		self.tiles = self.map('tiles')

		self.events = {}
		for i, o in ipairs(self.map('events').objects) do
			self.events[o.name] = o
		end
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
