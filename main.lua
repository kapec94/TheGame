-- This is the Game.

vec = require "hump.vector"
class = require "hump.class"

require "Config"

vec.unpack = function (self)
	return self.x, self.y
end

function dbg(msg, ...)
	if Config.Debug then
		print (string.format('[dbg] ' .. msg, ...))
	end
end

require "Colors"
require "Map"
require "Actors"
require "Camera"
require "GUI"
require "Fonts"

Game = {
	registerObject = function (self, object)
		self.obj_count = self.obj_count + 1
		dbg ('Registering object with id ' .. tostring(self.obj_count))

		object.id = self.obj_count
	end;

	pause = function (self, paused)
		if paused == nil then paused = true end
		dbg ('Settings Game.paused to ' .. tostring(paused))
		self.paused = paused
	end;

	addDrawable = function (self, obj, index)
		index = index or 5

		assert (obj.id)
		assert (obj.onDraw)
		assert (index >= 1 and index <= 10)

		self.layers[index][obj.id] = obj
		self.drawables[obj.id] = obj
	end;

	addActive = function (self, obj)
		assert (obj.id)
		assert (obj.onUpdate)
		self.actives[obj.id] = obj
	end;

	addInteractive = function (self, obj)
		assert (obj.id)
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

	obj_count = 0;
	keypressHooks = {};
	keyreleaseHooks = {};
	layers = {};
	drawables = {};
	actives = {};
	paused = false;

	onKeyPress = function (self, key)
		if key == 'escape' then
		--	love.event.quit()
		end
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
		for name, e in pairs(self.map.events) do
			local me = self.me
			local me_rect = {
				me.pos.x, me.pos.y,
				me.width, me.height
			}
			local sign_rect = {
				e.x, e.y,
				e.width, e.height
			}
			if rects_intersect(me_rect, sign_rect) then
				e:trigger(me)
			else
				-- Boy, that escalated quickly.
				e:kill(me)
			end
		end
	end;
}

function love.load()
	love.graphics.setMode(Config.Screen.Width, Config.Screen.Height)
	love.graphics.setFont(Fonts.get(Config.Font, 14))

	for i = 1, 10 do
		table.insert(Game.layers, {})
	end

	Game:registerObject(Game)
	Game:addInteractive(Game)
	Game:addActive(Game)

	GUI.HintButton:init()

	Game.map = Map(Config.Map)
	Game.me = Game.map.actors['me']
	assert (Game.me)

	local camera = Camera(Game.me)
	Game:addActive(camera)
	Game.camera = camera

	if Config.Debug then
		GUI.DebugInfo:init()
		GUI.DebugEventRenderer:init(Game.map)

		GUI.DebugInfo:show(10)
		GUI.DebugEventRenderer:show(2)
	end
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
	if not Game.paused then
		for id, o in pairs(Game.actives) do
			o:onUpdate(dt)
		end
	end
end

function love.draw()
	Game.camera:attach()
	for i=9, 1, -1 do
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
