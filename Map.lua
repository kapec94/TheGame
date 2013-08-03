local atl = require "atl"
atl.Loader.path = Config.resourcePath(Config.MapPath or '/')

local Event = class {
	init = function (self, atl_object, map)
		debug ('Loading event ' .. atl_object.name)

		self.id = Game:registerObject(self)
		self.name = atl_object.name
		self.x = atl_object.x
		self.y = atl_object.y
		self.width = atl_object.width
		self.height = atl_object.height
		self.atl = atl_object
		self.active = false
		self.map = map
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
			self.message = atl.properties['message']
			assert (self.message)

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

		init = function (self, atl, map)
			Event.init(self, atl, map)
			self.message = atl.properties['message']
			assert (self.message)
		end;

		onTrigger = function (self)
			debug ('Step into hint: \'' .. self.message .. '\'')
			GUI.HintButton:setActive()
			GUI.HintButton:setMessage(self.message)
		end;

		onKill = function (self)
			GUI.HintButton:setActive(false)
		end;
	},

	['remove'] = class {
		__includes = Event;

		init = function (self, atl, map)
			Event.init(self, atl, map)

			self.target = self.atl.properties['event']
			assert (self.target)
		end;

		onTrigger = function (self)
			debug ('Removing event ' .. self.target)
			self.map.events[self.target]:kill(self)
			self.map.events[self.target] = nil

			-- Autodestroying.
			self.map.events[self.name] = nil
		end;
	}
}

Map = class {
	init = function (self, name)
		self.id = Game:registerObject(self)

		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")
		self.width = self.map.width
		self.height = self.map.height

		self.tileWidth = self.map.tileWidth
		self.tileHeight = self.map.tileHeight

		self.tiles = self.map('tiles')

		self.events = {}
		self.actors = {}
		for i, o in ipairs(self.map('events').objects) do
			local event = Events[o.type]
			self.events[o.name] = event and event(o, self) or Event(o, self)
		end
		for i, o in ipairs(self.map('actors').objects) do
			local actor = Actors[o.type]
			if actor == nil then debug ('UNKNOWN ACTOR ' .. o.type) end
			self.actors[o.name] = actor and actor(o, self) or nil
		end

		self.map('events').visible = false
		self.map('actors').visible = false
	end;

	sample = function (self, x, y)
		return self.tiles(math.floor(x / self.tileWidth), math.floor(y / self.tileHeight))
	end;

	isCollidable = function (self, x, y)
		local tile = self:sample(x, y)
		return tile ~= nil or
			x >= self.width * self.tileWidth or
			x < 0 or
			y >= self.height * self.tileHeight or
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