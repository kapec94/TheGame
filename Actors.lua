local Actor = class {
	init = function (self, atl_object, map)
		assert (map)

		self.x = atl_object.x
		self.y = atl_object.y
		self.width = atl_object.width
		self.height = atl_object.height

		self.id = Game:registerObject(self)
		self.map = map
	end;
}

Actors = {
	Actor = Actor,
	['Player'] = Player,
	['Block'] = class {
		__include = Actor;

		init = function (self, atl_object, map)
			Actor.init(self, atl_object, map)
			Game:addDrawable(self, 1)
		end;

		onDraw = function (self)
			love.graphics.setColor(Colors.red)
			love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
		end;
	}
}

