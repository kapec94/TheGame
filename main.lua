-- This is the Game.

vec 	= require "hump.vector"
class 	= require "hump.class"

Config		= require "settings"
Colors		= require "colors"
GameObject 	= require "gameobject"
Map			= require "map"
Tile		= Map.Tile
Player		= require "player"
Camera		= require "camera"

Game = {
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
	
	keypressHooks 		= {};
	keyreleaseHooks		= {};
	drawables 			= {};
	actives 			= {};

	onKeyPress = function (self, key)
		if key == 'escape' then
			love.event.quit()
		end
	end;

	onDraw = function (self)
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
	end;
}

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)

	for i = 1, 10 do
		table.insert(Game.drawables, {})
	end

	love.graphics.setBackgroundColor(Colors.black)

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
end

function love.draw()
	Game.camera:attach()
	for i=1, 9 do
		local d = Game.drawables[i]
		for _, v in ipairs(d) do
			v:onDraw()
		end
	end

	Game.camera:detach()
	for _, v in ipairs(Game.drawables[10]) do
		v:onDraw()
	end
end

function love.quit()
	love.event.quit()
end

love.run()
