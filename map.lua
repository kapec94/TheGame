local atl = require "atl"
atl.Loader.path = Config.resourcePath(Config.MapPath or '/')

local Event = class {
	init = function (self, atl_object)
		self.id = Game:registerObject(self)
		self.x = atl_object.x
		self.y = atl_object.y
		self.width = atl_object.width
		self.height = atl_object.height
		self.atl = atl_object
		self.active = false
	end;

	trigger = function (self)
		if not self.active then
			self:onTrigger()
			self.active = true
		end
	end;

	kill = function (self)
		if self.active then
			self:onKill()
			self.active = false
		end
	end;

	onTrigger = function (self) end;
	onKill = function (self) end;
}

local Events = {
	['sign'] = class {
		__includes = Event;

		init = function (self, atl)
			Event.init(self, atl)
			self.message = atl.name
			self.label = GUI.Message.Label()

			self.label.message = self.message
			self.label.x = tonumber(atl.properties['x'] or 10)
			self.label.y = tonumber(atl.properties['y'] or 10)
		end;

		onTrigger = function (self)
			self.label:show(10)
		end;

		onKill = function (self)
			self.label:hide()
		end;

		onDraw = function (self)
			love.graphics.push()
			love.graphics.setColor(Colors.green)
			love.graphics.printf(self.atl.name, self.x - self.width / 2, self.y - self.height / 2, self.width * 2, 'center')
			love.graphics.pop()
		end;
	},

	-- Note to self. Hints SHALT NOT INTERSECT THEMSELVES.
	['hint'] = class {
		__includes = Event;

		init = function (self, atl)
			Event.init(self, atl)
			self.message = atl.name
		end;

		onTrigger = function (self)
			debug ('Step into hint: \'' .. self.message .. '\'')
			GUI.HintButton:setActive()
			GUI.HintButton:setMessage(self.message)
		end;

		onKill = function (self)
			GUI.HintButton:setActive(false)
		end;
	}
}

local Map = class {
	Tile = {};

	init = function (self, name)
		self.id = Game:registerObject(self)

		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")
		self.width = self.map.width
		self.height = self.map.height

		Tile.Width = self.map.tileWidth
		Tile.Height = self.map.tileHeight

		self.tiles = self.map('tiles')

		self.events = {}
		self.map('events').visible = Config.Debug
		for i, o in ipairs(self.map('events').objects) do
			if o.type == 'spawn' then
				self.spawn = Event(o)
			else
				local event = Events[o.type]
				table.insert(self.events, event and event(o) or Event(o))
			end
		end
	end;

	sample = function (self, x, y)
		return self.tiles(math.floor(x / Tile.Width), math.floor(y / Tile.Height))
	end;

	isCollidable = function (self, x, y)
		local tile = self:sample(x, y)
		return tile ~= nil or
			x >= self.width * Tile.Width or
			x < 0 or
			y >= self.height * Tile.Height or
			y < 0
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
