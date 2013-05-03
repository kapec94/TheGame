-- This is the Game.

vec 	= require "hump.vector"
class 	= require "hump.class"
hc 		= require "HardonCollider"
shapes 	= require "HardonCollider.shapes"

Config		= require "settings"
Colors		= require "colors"
GameObject 	= require "gameobject"
Map, Tile	= require "map" ()
Player		= require "player"

shapes.newRectangleShape = function (x, y, w, h)
	return shapes.newPolygonShape(x,y, x+w,y, x+w,y+h, x,y+h)
end

Game = {
	setMap = function (self, map)
		self.activeMap = map
	end;

	getMap = function (self)
		return self.activeMap
	end;

	addDrawable = function (self, obj, index)
		index = index or 5

		assert (obj)	
		assert (obj.onDraw)
		assert (index >= 1 and index <= 10)
		
		table.insert(self.drawables[index], obj)
	end;
	
	addActive = function (self, obj)
		assert (obj.onUpdate)
		table.insert(self.actives, obj)
	end;
	
	addInteractive = function (self, obj)
		assert (obj.onKeyPress ~= nil or obj.onKeyRelease ~= nil)
		if obj.onKeyPress then
			table.insert(self.keypressHooks, obj) 
		end
		if obj.onKeyRelease then 
			table.insert(self.keyreleaseHooks, obj) 
		end
	end;

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
	end;

	removeDrawable = function (self, obj)
		table.remove(self.drawables, obj)
	end;
	
	removeActive = function (self, obj)
		table.remove(self.actives, obj)
	end;
	
	removeInteractive = function (self, obj)
		table.remove(self.keypressHooks, obj)
		table.remove(self.keyreleaseHooks, obj)
	end;

	removeCollidable = function (self, obj)
		self.collisionHooks[obj] = nil
		self.collisionEndHooks[obj] = nil
		self.activeShapes[obj] = nil
	end;

	keypressHooks 		= {};
	keyreleaseHooks		= {};
	drawables 			= {};
	actives 			= {};
	shapes 				= {};
	collisionHooks 		= {};
	collisionEndHooks 	= {};

	collider 			= nil; 

	statusText 			= nil;
	activeMap 			= nil;

	onKeyPress = function (self, key)
		if key == 'escape' then
			love.event.quit()
		end
	end;

	onDraw = function (self)
		love.graphics.setColor(Colors.orange)
		love.graphics.print(string.format("FPS: %s\np.v = %s;\np.pos = {%s, %s}", 
			love.timer.getFPS(), me.v, me.pos.x, me.pos.y), 
			10, 10)
	end;
}

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)

	for i = 1, 10 do
		table.insert(Game.drawables, {})
	end

	Game:addInteractive(Game)
	Game:addDrawable(Game, 10)

	Game.collider = hc(Tile.Width, on_collision, on_collision_end);

	map = Map("test")
	Game:setMap(map)
	Game:addDrawable(map)
	
	me = Player(50, 50)
	Game:addActive(me)
	Game:addInteractive(me)
	Game:addDrawable(me)
	Game:addCollidable(me, true)

	local map_data = {
		0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
		1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
		1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0,
		1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	}
	for y = 0, map.Height - 1 do
		for x = 0, map.Width - 1 do
			map:setTile(x, y, map_data[y * map.Width + x + 1] == 1)
		end
	end
	for _, t in ipairs(map:getFilledTiles()) do
		Game:addCollidable(t, false)
	end
end

function love.keypressed(key, unicode)
	for _,o in ipairs(Game.keypressHooks) do
		o:onKeyPress(key)
	end
end

function love.keyreleased(key, unicode)
	for _,o in ipairs(Game.keyreleaseHooks) do
		o:onKeyRelease(key)
	end
end

function love.update(dt)
	for _,o in ipairs(Game.actives) do
		o:onUpdate(dt)
	end
	Game.collider:update(dt)
end

function love.draw()
	for _, d in ipairs(Game.drawables) do
		for _, v in ipairs(d) do
			v:onDraw()
		end
	end
end

function on_collision(dt, shape_a, shape_b, dx, dy)
	local obj_a = Game.shapes[shape_a]
	local obj_b = Game.shapes[shape_b]

	if obj_a.onCollision then obj_a:onCollision(dt, shape_b, dx, dy) end
	if obj_b.onCollision then obj_b:onCollision(dt, shape_a, -dx, -dy) end
end

function on_collision_end(dt, shape_a, shape_b, dx, dy)
	local obj_a = Game.shapes[shape_a]
	local obj_b = Game.shapes[shape_b]

	if obj_a.onCollisionEnd then obj_a:onCollisionEnd(dt, shape_b, dx, dy) end
	if obj_b.onCollisionEnd then obj_b:onCollisionEnd(dt, shape_a, -dx, -dy) end
end

function love.quit()
	love.event.quit()
end

love.run()
