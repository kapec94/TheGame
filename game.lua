Game = {
	setMap = function (self, map)
		self.__activeMap = map
	end,
	getMap = function (self)
		return self.__activeMap
	end,

	addDrawable = function (self, obj, index)
		index = index or 5

		assert (obj)	
		assert (obj.onDraw)
		assert (index >= 1 and index <= 10)
		
		table.insert(self.drawables[index], obj)
	end,
	
	addActive = function (self, obj)
		assert (obj.onUpdate)
		table.insert(self.actives, obj)
	end,
	
	addInteractive = function (self, obj)
		assert (obj.onKeyPress ~= nil or obj.onKeyRelease ~= nil)
		if obj.onKeyPress then
			table.insert(self.keypressHooks, obj) 
		end
		if obj.onKeyRelease then 
			table.insert(self.keyreleaseHooks, obj) 
		end
	end,

	addCollidable = function (self, obj, active)
		active = active or true
		
		assert (obj)
		assert (obj.getShape)
		
		local shape = obj:getShape()
		self.collider:addShape(shape)
		if active == false then 
			self.collider:setPassive(shape)
		end
		self.shapes[shape] = obj

		if obj.onCollision then
			self.collisionHooks[shape] = obj
		end
		if obj.onCollisionEnd then
			self.collisionEndHooks[shapes] = obj
		end
	end,

	removeDrawable = function (self, obj)
		table.remove(self.drawables, obj)
	end,
	
	removeActive = function (self, obj)
		table.remove(self.actives, obj)
	end,
	
	removeInteractive = function (self, obj)
		table.remove(self.keypressHooks, obj)
		table.remove(self.keyreleaseHooks, obj)
	end,

	removeCollidable = function (self, obj)
		self.collisionHooks[obj] = nil
		self.collisionEndHooks[obj] = nil
		self.activeShapes[obj] = nil
	end,

	keypressHooks = {},
	keyreleaseHooks = {},
	drawables = util.rep({}, 10),
	actives = {},

	shapes = {},
	collisionHooks = {},
	collisionEndHooks = {},

	collider = hc(Tile.static.Width, function(...) on_collision(...) end, function (...) on_collision_end(...) end),

	__statusText = nil,
	__activeMap = nil,

	onKeyPress = function (self, key)
		if key == 'escape' then
			love.event.quit()
		end
	end,
	onDraw = function (self)
		love.graphics.setColor(Colors.orange)
		love.graphics.print(string.format("FPS: %s\np.v = %s;\np.pos = {%s, %s}", 
			love.timer.getFPS(), me.v, me.pos.x, me.pos.y), 
			10, 10)
	end
}

Game:addInteractive(Game)
Game:addDrawable(Game, 10)
