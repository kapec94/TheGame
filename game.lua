Game = {
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

	keypressHooks = {},
	keyreleaseHooks = {},
	drawables = util.rep({}, 10),
	actives = {},

	__statusText = nil,

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
