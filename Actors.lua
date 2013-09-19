local Actor = class {
	isActor = true;

	init = function (self, atl_object, map)
		self.name = string.format('Actor.%s$%s', atl_object.type, atl_object.name)
		self.width = atl_object.width
		self.height = atl_object.height
		self.x = atl_object.x + self.width / 2
		self.y = atl_object.y + self.height / 2
		self.map = map

		assert (self.map)

		Game:registerObject(self)
	end;
}

local Collidable = class {
	__includes = Actor;
	isCollidable = true;
	name = 'Collidable';

	init = function (self, atl_object, map)
		Actor.init(self, atl_object, map)

		self.v = vec(0, 0)
		self.falling = true

		self.map:addCollidable(self)
	end;

	hitTest = function (self, x, y)
		return x < self.width and x >= 0 and y < self.height and y >= 0
	end;

	onUpdate = function (self, dt)
		local function sign(n)
			return n ~= 0 and math.abs(n) / n or 0
		end

		local map = self.map
		local w, h = self.width, self.height

		self.map:setCurrentCollidable(self)

		if not map:hitTest(self.x - w / 2 + 1, self.y + h / 2) and not map:hitTest(self.x + w / 2 - 1, self.y + h / 2) then
			self.v = self.v + Config.Gravity * dt
			self.falling = true
		end

		-- Collision detection
		local dx, dy = vec.unpack(self.v * dt)
		local collision, obj
		local obj_x, obj_y

		local x, y = self.x + dx, self.y + dy

		if dx ~= 0 then
			local dir = sign(dx)
			local pos = x + dir * w / 2
			local objs = {}

			dx = 0

			collision, obj = map:hitTest(pos, self.y - h / 2 + 1)
			if collision then
				table.insert(objs, obj)
			end

			collision, obj = map:hitTest(pos, self.y + h / 2 - 1)
			if collision then table.insert(objs, obj) end

			for i, obj in ipairs(objs) do
				local cpos = obj.x - dir * obj.width / 2

				local new_dx = pos - cpos
				if math.abs(new_dx) > math.abs(dx) then
					dx = new_dx
					obj_x = obj
				end
			end
		end

		if dy ~= 0 then
			local dir = sign(dy)
			local pos = y + dir * h / 2
			local objs = {}

			dy = 0

			collision, obj = map:hitTest(self.x - w / 2 + 1, pos)
			if collision then
				table.insert(objs, obj)
			end

			collision, obj = map:hitTest(self.x + w / 2 - 1, pos)
			if collision then
				table.insert(objs, obj)
			end

			for i, obj in ipairs(objs) do
				local cpos = obj.y - dir * obj.height / 2
				local new_dy = pos - cpos
				if math.abs(new_dy) > math.abs(dy) then
					dy = new_dy
					obj_y = obj
				end
			end
		end

		self.x = x
		self.y = y

		if dx ~= 0 then
			self:onCollision(obj_x, dx, 0)
			obj_x:onCollision(self, -dx, 0)
		end

		if dy ~= 0 then
			self:onCollision(obj_y, 0, dy)
			obj_y:onCollision(self, 0, -dy)
		end
	end;

	onCollision = function (self, collidable, dx, dy)
		if dx ~= 0 then
			self.v.x = 0
		end
		if dy ~= 0 then
			self.v.y = 0
			self.falling = false
		end

		if collidable.isMap then
			self.x = self.x - dx
			self.y = self.y - dy
		end
	end;
}

Actors = {
	['player'] = class {
		__includes = Collidable;
		isPlayer = true;

		Color = Colors.blue;
		Speed = vec(200, 200);

		init = function (self, atl_object, map)
			Collidable.init(self, atl_object, map)

			self.moveleft = false
			self.moveright = false

			Game:addDrawable(self, 1)
			Game:addActive(self)
			Game:addInteractive(self)
		end;

		onDraw = function (self)
			love.graphics.setColor(self.Color)
			love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2,
				self.width, self.height)
		end;

		onKeyPress = function (self, key)
			if key == 'left' then
				self.moveleft = true
			end
			if key == 'right' then
				self.moveright = true
			end
			if key == ' ' then
				if not self.falling then
					self.v.y = -math.sqrt(3 * 4 * Config.Gravity.y * self.height)
				end
			end
		end;

		onKeyRelease = function (self, key)
			if key == 'left' and self.moveleft == true then
				self.moveleft = false
			end
			if key == 'right' and self.moveright == true then
				self.moveright = false
			end
		end;

		onUpdate = function (self, dt)
			self.v.x = (self.moveleft and -self.Speed.x or 0) + (self.moveright and self.Speed.x or 0)
			self.__includes.onUpdate(self, dt)
		end;

		onCollision = function (self, collidable, dx, dy)
			self.__includes.onCollision(self, collidable, dx, dy)
			if collidable.isBlock then
				self.y = self.y - dy
			end
		end;
	},

	['block'] = class {
		__includes = Collidable;
		isBlock = true;

		init = function (self, atl_object, map)
			Collidable.init(self, atl_object, map)

			Game:addDrawable(self, 1)
			Game:addActive(self)
		end;

		onDraw = function (self)
			love.graphics.setColor(Colors.red)
			love.graphics.rectangle('fill', self.x - self.width / 2, self.y - self.height / 2,
				self.width, self.height)
		end;

		onCollision = function (self, collidable, dx, dy)
			self.__includes.onCollision(self, collidable, dx, dy)
			if collidable.isPlayer then
				self.x = self.x - dx
			end
		end;
	},

	['door'] = class {
		__includes = Collidable;
		isDoor = true;

		-- Well it is a hack, but there's nothing wrong in it.
		isMap = true;

		init = function (self, atl_object, map)
			self.__includes.init(self, atl_object, map)
			Game:addDrawable(self, 2)
		end;

		open = function (self)
			dbg ('Opening door.')
			self.map:removeCollidable(self)
			Game:removeDrawable(self)
		end;

		close = function (self)
			dbg ('Closing door.')
			self.map:addCollidable(self)
			Game:addDrawable(self, 2)
		end;

		onDraw = function (self)
			love.graphics.setColor(Colors.orange)
			love.graphics.rectangle('fill', self.x - self.width / 2, self.y - self.height / 2,
				self.width, self.height)
		end;
	},

	['bridge'] = class {
		__includes = Collidable;
		isDoor = true;

		-- Well it is a hack, but there's nothing wrong in it.
		isMap = true;

		init = function (self, atl_object, map)
			self.__includes.init(self, atl_object, map)
			self.map:removeCollidable(self)
		end;

		open = function (self)
			dbg ('Opening bridge.')
			self.map:addCollidable(self)
			Game:addDrawable(self, 2)
		end;

		close = function (self)
			dbg ('Closing bridge.')
			self.map:removeCollidable(self)
			Game:removeDrawable(self)
		end;

		onDraw = function (self)
			love.graphics.setColor(Colors.white)
			love.graphics.rectangle('fill', self.x - self.width / 2, self.y - self.height / 2,
				self.width, self.height)
		end;
	},

	['spawn'] = class {
		__includes = Actor;

		init = function (self, atl_object, map)
			self.__includes.init(self, atl_object, map)

			self.actor = atl_object.properties['actor']
			assert (self.actor)
		end;

		spawn = function (self)
			dbg ('Spawning actor %s', self.actor)
			local actor = self.map.actors[self.actor]
			assert (actor)

			actor.x = self.x
			actor.y = self.y

			if actor.v then actor.v = vec(0, 0) end
		end;
	},
}

