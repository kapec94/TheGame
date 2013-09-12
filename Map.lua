local atl = require "atl"
atl.Loader.path = 'res/maps/'

local Event = class {
	init = function (self, atl_object, map)
		dbg ('Loading event ' .. atl_object.name)

		Game:registerObject(self)
		self.name = atl_object.name
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
}

Map = class {
	-- Type assertions for the poor.
	isMap = true;

	currentCollidableId = 0;
	events = {};
	actors = {};
	collidables = {};

	init = function (self, name)
		self.name = name
		self.map = atl.Loader.load(name .. ".tmx")

		self.width = self.map.width
		self.height = self.map.height
		self.tileWidth = self.map.tileWidth
		self.tileHeight = self.map.tileHeight
		self.defaultActor = self.map.properties['defaultActor']

		self.tiles = self.map('tiles')

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
		return self.tiles(math.floor(x / self.tileWidth), math.floor(y / self.tileHeight))
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

		if tile ~= nil then return true, self end
		if x >= self.width * self.tileWidth or
			x < 0 or
			y >= self.height * self.tileHeight or
			y < 0
		then
			return true, self
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
