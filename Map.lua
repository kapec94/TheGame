local atl = require "atl"
atl.Loader.path = 'res/maps/'

local Event = class {
	init = function (self, atl_object, map)
		self.name = string.format('Event.%s$%s', atl_object.type, atl_object.name)
		self.width = atl_object.width
		self.height = atl_object.height
		self.x = atl_object.x + self.width / 2
		self.y = atl_object.y + self.height / 2
		self.atl = atl_object
		self.active = false
		self.map = map
		self.object = atl_object.properties['object'] or self.map.defaultActor

		assert (self.map)
		assert (self.object)

		Game:registerObject(self)
		Game:addActive(self)
	end;

	onUpdate = function (self, dt)
		local function rects_intersect(r1, r2)
			-- found on StackOverflow.
			-- [1] - left
			-- [2] - top
			-- [3] - width
			-- [4] - height
			return not (r2[1] > r1[1] + r1[3] or
				r2[1] + r2[3] < r1[1] or
				r2[2] > r1[2] + r1[4] or
				r2[2] + r2[4] < r1[2])
		end

		local obj = self.map.actors[self.object]
		assert (obj)

		local obj_rect = {
			obj.x - obj.width / 2, obj.y - obj.height / 2,
			obj.width, obj.height
		}
		local self_rect = {
			self.x - self.width / 2, self.y - self.height / 2,
			self.width, self.height
		}
		if rects_intersect(obj_rect, self_rect) then
			self:trigger()
		else
			self:kill()
		end
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

		init = function (self, atl, map)
			Event.init(self, atl, map)
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
			self.map:removeEvent(self.target)
			self.map:removeEvent(self.name)
		end;
	},

	['trap'] = class {
		__includes = Event;

		init = function (self, atl, map)
			Event.init(self, atl, map)

			self.target = self.atl.properties['target']
			self.triggerMethod = self.atl.properties['trigger']
			self.killMethod = self.atl.properties['kill']
			assert (self.target)
			assert (self.triggerMethod or self.killMethod)
		end;

		_call = function (self, object, method)
			assert (object)

			local fn = object[method]
			assert (fn)

			object[method](object)
		end;

		onTrigger = function (self)
			if self.triggerMethod then
				dbg ('trap %s activated. Calling %s:%s.', self.name, self.target, self.triggerMethod)
				self:_call(self.map.actors[self.target], self.triggerMethod)
			end
		end;

		onKill = function (self)
			if self.killMethod then
				dbg ('trap %s deactivated. Calling %s:%s.', self.name, self.target, self.killMethod)
				self:_call(self.map.actors[self.target], self.killMethod)
			end
		end;
	},
}

local Tile = class {
	isMap = true;

	init = function (self, x, y, atl_obj, map)
		self.map = map
		assert (self.map)

		self.width = atl_obj.width
		self.height = atl_obj.height
		self.x = x * self.width + self.width / 2
		self.y = y * self.height + self.height / 2
		self.atl = atl_obj
		self.name = string.format('Tile(%d, %d)', x, y)
	end;

	onCollision = function (self, collidable, dx, dy)
	end;
}

Map = class {
	currentCollidableId = 0;
	events = {};
	actors = {};
	collidables = {};

	tiles = {};

	init = function (self, name)
		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")

		self.width = self.map.width
		self.height = self.map.height
		self.tileWidth = self.map.tileWidth
		self.tileHeight = self.map.tileHeight
		self.defaultActor = self.map.properties['defaultActor']

		for x, y, tile in self.map('tiles'):iterate() do
			self.tiles[y * self.width + x] = Tile(x, y, tile, self.map) or nil
		end

		for i, o in ipairs(self.map('events').objects) do
			local event = Events[o.type]
			self.events[o.name] = event and event(o, self) or Event(o, self)
		end
		for i, o in ipairs(self.map('actors').objects) do
			local actor = Actors[o.type]
			if actor ~= nil then
				self.actors[o.name] = actor(o, self)
			else
				dbg ('UNKNOWN ACTOR ' .. o.type)
			end
		end

		self.map('events').visible = false
		self.map('actors').visible = false

		Game:registerObject(self)
		Game:addDrawable(self)
	end;

	sample = function (self, x, y)
		x, y = math.floor(x / self.tileWidth), math.floor(y / self.tileHeight)
		return self.tiles[y * self.width + x]
	end;

	removeEvent = function (self, event_name)
		local event = self.events[event_name]

		Game:removeActive(event)
		event:kill()

		self.events[event_name] = nil
	end;

	addCollidable = function (self, obj)
		assert (obj.hitTest)
		self.collidables[obj.id] = obj
	end;

	removeCollidable = function (self, obj)
		self.collidables[obj.id] = nil
	end;

	setCurrentCollidable = function (self, obj)
		self.currentCollidableId = obj.id
	end;

	hitTest = function (self, x, y)
		local tile = self:sample(x, y)

		if tile ~= nil then
			return true, tile
		end
		for i, o in pairs(self.collidables) do
			if self.currentCollidableId ~= o.id then
				if o:hitTest(x - o.x + o.width / 2, y - o.y + o.height / 2) then
					return true, o
				end
			end
		end
		return false
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
