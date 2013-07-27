-- This is the Game.

vec = require "hump.vector"
class = require "hump.class"

vec.unpack = function (self)
	return self.x, self.y
end

function debug(msg, ...)
	if Config.Debug then
		print ('[debug]', msg, ...)
	end
end

Config = require "settings"
Colors = require "colors"
Map = require "map"
Tile = Map.Tile
Player = require "player"
Camera = require "camera"

Game = {
	registerObject = function (self, object)
		self.obj_count = self.obj_count + 1
		debug ('Registering object with id', self.obj_count)
		return self.obj_count
	end;

	addDrawable = function (self, obj, index)
		index = index or 5

		assert (obj)	
		assert (obj.onDraw)
		assert (index >= 1 and index <= 10)

		self.layers[index][obj.id] = obj
		self.drawables[obj.id] = obj
	end;
	
	addActive = function (self, obj)
		assert (obj.onUpdate)
		self.actives[obj.id] = obj
	end;
	
	addInteractive = function (self, obj)
		assert (obj.onKeyPress ~= nil or obj.onKeyRelease ~= nil)
		if obj.onKeyPress then
			self.keypressHooks[obj.id] = obj
		end
		if obj.onKeyRelease then
			self.keyreleaseHooks[obj.id] = obj 
		end
	end;

	removeDrawable = function (self, obj)
		self.drawables[obj.id] = nil
	end;
	
	removeActive = function (self, obj)
		self.actives[obj.id] = nil
	end;
	
	removeInteractive = function (self, obj)
		self.keypressHooks[obj.id] = nil
		self.keyreleaseHooks[obj.id] = nil
	end;
	
	obj_count			= 0;
	keypressHooks 		= {};
	keyreleaseHooks		= {};
	layers				= {};
	drawables			= {};
	actives 			= {};

	onKeyPress = function (self, key)
		if key == 'escape' then
			love.event.quit()
		end
	end;

	onDraw = function (self)
		if Config.Debug then
			love.graphics.setColor(Colors.orange)
			local me = self.me
			local col = me.collisions
			love.graphics.print(string.format(
				"FPS: %s\n" ..
				"p.v = %s;\np.pos = %s\n" ..
				"falling = %s",
				love.timer.getFPS(), 
				tostring(me.v), tostring(me.pos),
				tostring(me.falling)), 
			10, 10)
		end
	end;
}

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)

	for i = 1, 10 do
		table.insert(Game.layers, {})
	end

	love.graphics.setBackgroundColor(Colors.black)

	Game.id = Game:registerObject(Game)
	Game:addInteractive(Game)
	Game:addDrawable(Game, 10)

	local map = Map("test")
	Game:addDrawable(map)
	Game.map = map

	local spawnEvent = map.events['spawn']
	local me = Player(spawnEvent.x, spawnEvent.y)
	Game:addActive(me)
	Game:addInteractive(me)
	Game:addDrawable(me)
	Game.me = me

	local camera = Camera(me)
	Game:addActive(camera)
	Game.camera = camera
end

function love.keypressed(key, unicode)
	for id, o in pairs(Game.keypressHooks) do
		o:onKeyPress(key)
	end
end

function love.keyreleased(key, unicode)
	for id, o in pairs(Game.keyreleaseHooks) do
		o:onKeyRelease(key)
	end
end

function love.update(dt)
	for id, o in pairs(Game.actives) do
		o:onUpdate(dt)
	end
end

function love.draw()
	Game.camera:attach()
	for i=1, 9 do
		local l = Game.layers[i]
		for id, v in pairs(l) do
			if Game.drawables[id] ~= nil then
				v:onDraw()
			else
				l[id] = nil
			end
		end
	end

	Game.camera:detach()
	for id, v in pairs(Game.layers[10]) do
		if Game.drawables[id] ~= nil then
			v:onDraw()
		else
			Game.layers[10][id] = nil
		end
	end
end

function love.quit()
	love.event.quit()
end

love.run()
