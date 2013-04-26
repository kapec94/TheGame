Game = {
	addDrawable = function (self, obj)
		assert (obj.onDraw)
		table.insert(self.drawables, obj)
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
	drawables = {},
	actives = {},

	onKeyPress = function (self, key)
		if key == 'escape' then
			love.event.quit()
		end
	end
}

Game:addInteractive(Game)