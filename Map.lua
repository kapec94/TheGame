local atl = require "atl"
atl.Loader.path = 'res/maps/'

local Event = class {
	init = function (self, atl_object, map)
		dbg ('Loading event ' .. atl_object.name)

		Game:registerObject(self)
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
			dbg ('Step into hint: \'' .. self.message .. '\'')
			GUI.HintButton:setActive()
			GUI.HintButton.message = self.message
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
			dbg ('Removing event ' .. self.target)
			self.map.events[self.target]:kill(self)
			self.map.events[self.target] = nil

			-- Autodestroying.
			self.map.events[self.name] = nil
		end;
	}
}

Map = class {
	-- Type assertions for the poor.
	isMap = true;

	init = function (self, name)
		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")
		self.width = self.map.width
		self.height = self.map.height

		self.tileWidth = self.map.tileWidth
		self.tileHeight = self.map.tileHeight

		self.tiles = self.map('tiles')

		self.currentCollidableId = 0

		self.events = {}
		self.actors = {}
		self.collidables = {}
		for i, o in ipairs(self.map('events').objects) do
			local event = Events[o.type]
			self.events[o.name] = event and event(o, self) or Event(o, self)
		end
		for i, o in ipairs(self.map('actors').objects) do
			local actor = Actors[o.type]
			if actor == nil then dbg ('UNKNOWN ACTOR ' .. o.type) end
			self.actors[o.name] = actor and actor(o, self) or nil
		end

		self.map('events').visible = false
		self.map('actors').visible = false

		Game:registerObject(self)
		Game:addDrawable(self)
	end;

	sample = function (self, x, y)
		return self.tiles(math.floor(x / self.tileWidth), math.floor(y / self.tileHeight))
	end;

	flagCollidable = function (self, obj)
		assert (obj.hitTest)
		table.insert(self.collidables, obj)
	end;

	setCurrentCollidable = function (self, obj)
		self.currentCollidableId = obj.id
	end;

	hitTest = function (self, x, y)
		local tile = self:sample(x, y)

		if tile ~= nil then return true, self end
		if x >= self.width * self.tileWidth or
			x < 0 or
			y >= self.height * self.tileHeight or
			y < 0
		then
			return true, self
		end
		for i, o in ipairs(self.collidables) do
			if self.currentCollidableId ~= o.id then
				if o:hitTest(x - o.x + o.width / 2, y - o.y + o.height / 2) then
					return true, o
				end
			end
		end
		return false
	end;

	onCollision = function (self, collidable, dx, dy)
		-- Well, we don't give a shit, as we're the damn world!
	end;

	onDraw = function (self)
		local cam = Game.camera
		local w, h = love.graphics.getWidth(), love.graphics.getHeight()
		local x, y = cam.x, cam.y

		self.map:setDrawRange(x - w / 2, y - h / 2, w, h)

		love.graphics.setColor(Colors.white)
		self.map:draw()
	end;
}
