local Actor = class {
	isActor = true;

	init = function (self, atl_object, map)
		dbg ('Loading actor ' .. atl_object.name)

		self.name = atl_object.name
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

	init = function (self, atl_object, map)
		Actor.init(self, atl_object, map)

		self.v = vec(0, 0)
		self.falling = true

		self.map:addCollidable(self)
	end;

	hitTest = function (self, x, y)
		return x < self.width and x >= 0 and y < self.height and y >= 0
	end;

	-- wow, now that's obsfucated function, ain't it.
	-- pos - current object position in given dimention
	-- dr - moving offset
	-- collision_fn - boolean function checking if there's a collision going
	-- object_size - object's size in given dimention
	-- RETURN VALUE:
	-- * <bool indicating if there is a collision to resolve>,
	-- * <new position>,
	-- * <object we just collided with (in any)>,
	-- * <how 'far' we're in this object (if any)>
	resolve_collision = function (self, pos, dr, object_size, collision_fn)
		local function clamp(val)
			if math.abs(val) > 1 then
				return math.abs(val) / val
			else
				return val
			end
		end

		-- Maximum distance object can go in one iteration, in pixels
		local step = 40

		local t = 1
		local s = object_size / 2
		local round = math.floor
		dr = dr / step
		if dr < 0 then
			dr = math.abs(dr)
			t = -t
			s = -s
			round = math.ceil
		end
		while dr ~= 0 do
			local newpos = pos + clamp(dr) * t * step
			local collides, obj = collision_fn(newpos + s)
			if collides then
				local delta = newpos - pos
				while collision_fn(pos + delta + s) do
					delta = delta - clamp(delta)
				end
				return true, newpos, obj, newpos - pos - delta
			else
				pos = newpos
				dr = dr - math.abs(t)
				if dr < 0 then dr = 0 end
			end
		end
		return false, pos, nil, 0
	end;

	onUpdate = function (self, dt)
		local map = self.map
		local x, y = self.x, self.y
		local w, h = self.width, self.height

		self.map:setCurrentCollidable(self)

		-- Gravity first of all.
		if not map:hitTest(x - w / 2 + 1, y + h / 2) and not map:hitTest(x + w / 2 - 1, y + h / 2) then
			self.v = self.v + Config.Gravity * dt
			self.falling = true
		end

		local hitTestX = function (x)
			local collision, obj = map:hitTest(x, y - h / 2 + 1)
			if collision then return true, obj end

			collision, obj = map:hitTest(x, y + h / 2 - 1)
			if collision then return true, obj end
		end
		local hitTestY = function (y)
			local collision, obj = map:hitTest(x - w / 2 + 1, y)
			if collision then return true, obj end

			collision, obj = map:hitTest(x + w / 2 - 1, y)
			if collision then return true, obj end
		end

		local x_collision, x, obj_x, dx = self:resolve_collision(x, self.v.x * dt, w, hitTestX)
		local y_collision, y, obj_y, dy = self:resolve_collision(y, self.v.y * dt, h, hitTestY)

		self.x = x
		self.y = y

		if x_collision then
			obj_x:onCollision(self, -dx, 0)
			self:onCollision(obj_x, dx, 0)
		end
		if y_collision then
			obj_y:onCollision(self, 0, -dy)
			self:onCollision(obj_y, 0, dy)
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
	['Player'] = class {
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

	['Block'] = class {
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
	}
}

