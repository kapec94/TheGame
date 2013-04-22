-- This is the Game.

-- {{{ GAME SETTINGS
GameSpeed = 0.4
Screen = {
	Width = 600,
	Height = 360 
}
Gravity = 10000
--}}}

-- {{{ COLORS
Colors = {
	white = { 255, 255, 255 },
	black = { 0, 0, 0 },
	cornflowerBlue = { 100, 149, 237 },
	orange = { 0xCC, 0x66, 0x00 }
}
-- }}}

-- {{ CLASS FRAMEWORK
function is_class(omg)
	return omg ~= nil and omg.__class__ == omg
end

function __super(Class)
	assert (is_class(Class.__extends__))

	super_mt = { __index = Class.__extends__, __call = Class.__extends__.__init__ }
	super = {}

	setmetatable (super, super_mt)
	return super
end

function class(body)
    local Class = body or {}
    local Class_mt = { __index = Class, __newindex = Class }
    
    if is_class(Class.__extends__) then
		print ("It inherits, wow!")
        local Base_mt = { __index = Class.__extends__, __newindex = Class.__extends__ }
        setmetatable(Class, Base_mt)
        
        Class.__super__ = __super(Class) 
    else
		print (Class.__extends__ == nil and "No __extends__" or "Invalid __extends__")
	end
    
    function Class.create(...)
        local obj = {}
        setmetatable(obj, Class_mt)
        
        if Class.__init__ then
            obj:__init__(...)
        else
			print ("[Warning] No Class.__init__; this looks error-prone!")
		end
        
        return obj
    end
    
    Class.__class__ = Class
    return Class
end

function static(body, ...)
	local Class = class(body)
	return Class.create(...)
end
-- }}

-- {{{ CLASS HIERARCHY
print ("GameObject")
GameObject = class({
	__init__ = function (self, x, y)
		self.x = x or 0
		self.y = y or 0
	end,

	x = 0,
	y = 0
})
print (is_class(GameObject))

print ("Moveable")
Moveable = class({
	__extends__ = GameObject,
	__init__ = function (self, x, y)
		self.__extends__:__init__(x, y)
		Game:addActive(self)
	end,

	move = function(self, dx, dy)
		self.x = self.x + dx
		self.y = self.y + dy
	end,
	addVelocity = function (self, dvx, dvy)
		self.vx = self.vx + dvx
		self.vy = self.vy + dvy
	end,
	onUpdate = function(self, dt)
		self:move(self.vx * dt, self.vy * dt)
	end,

	vx = 0,
	vy = 0
})
print (is_class(Moveable)) 

print ("Player")
Player = class({
	Width = 30,
	Height = 30,
	Color = Colors.cornflowerBlue,

	__extends__ = Moveable,
	__init__ = function (self, x, y)
		self:__super__(x, y)
		Game:addInteractive(self)
		Game:addDrawable(self)
		Game:addGravity(self)
	end,

	onKeyPress = {
		['left'] = function (self)
			self.vx = -100
		end,
		['right'] = function (self)
			self.vx = 100
		end,
		['up'] = function (self)
			self.vy = 100
		end,
		['down'] = function (self)
			self.vy = -100
		end
	},
	onKeyRelease = {
		['left'] = function (self)
			self.vx = 0
		end,
		['right'] = function (self)
			self.vx = 0
		end,
		['up'] = function (self)
			self.vy = 0
		end,
		['down'] = function (self)
			self.vy = 0
		end
	},
	 
	onDraw = function(self)
		love.graphics.setColor(self.Color)
		love.graphics.rectangle("fill", self.x, self.y,
			self.Width, self.Height)
	end
})
print (is_class(Player))

Map = class({
	Width = 12,
	Height = 12,

	__init__ = function (self)
	end,
	getTile = function (self, x, y)
		return self.tiles[y * Map.width + x]
	end,
	setTile = function (self, x, y, tile)
		self.tiles[y * Map.Width + x] = tile
		tile.x = x
		tile.y = y
	end,
	sample = function (self, ax, ay)
		return self:getTile(math.floor(x / Tile.width), math.floor(y / Tile.height))
	end,
	
	tiles = {}
})

Tile = class({
	Color = Colors.white,
	Width = Screen.Width / Map.Width,
	Height = Screen.Height / Map.Height,

	__extends__ = GameObject,
	__init__ = function(self, fill, x, y)
		self:__super__(x, y)
		self:setFill(fill)
	end,
	
	onDraw = function(self)
		love.graphics.setColor(self.Color)
		love.graphics.rectangle('fill',
			self.x * self.Width, self.y * self.Height,
			self.Width, self.Height)
	end,
	setFill = function(self, fill)
		if fill == false and self.filled == true then
			Game:removeDrawable(self)
		elseif fill == true and self.filled == false then
			Game:addDrawable(self)
		end
	end,

	filled = false
})
-- }}}

-- {{{ GAME OBJECT
Game = static({
	__init__ = function (self)
		self:addInteractive(self)
	end,

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
			print ("Keypress hook")
			table.insert(self.keypressHooks, obj) 
		end
		if obj.onKeyRelease then 
			print ("Keyrelease hook")
			table.insert(self.keyreleaseHooks, obj) 
		end
	end,
	addGravity = function (self, obj)
		assert (obj.addVelocity)
		table.insert(self.gravity, obj)
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
	removeGravity = function (self, obj)
		table.remove(self.gravity, obj)
	end,

	keypressHooks = {},
	keyreleaseHooks = {},
	drawables = {},
	actives = {},
	gravity = {},

	onKeyPress = {
		['escape'] = function (self)
			love.event.quit()
		end
	}
})
-- }}}

function love.load()
	love.graphics.setMode(Screen.Width, Screen.Height)

	me = Player.create()
	map = Map.create()

	for y = -1, Map.Height do
		for x = -1, Map.Width do
			map:setTile(x, y, Tile.create(y > Map.Height / 2))
		end
	end
end

function love.keypressed(key, unicode)
	print (string.format("KeyPress %s", key))
	for _,o in ipairs(Game.keypressHooks) do
		local a = o.onKeyPress
		if a[key] then a[key](o) end
	end
end

function love.keyreleased(key, unicode)
	print (string.format("KeyRelease %s", key))
	for _,o in ipairs(Game.keyreleaseHooks) do
		local a = o.onKeyRelease
		if a[key] then a[key](o) end 
	end
end

function love.update(dt)
	for _,o in ipairs(Game.gravity) do
		o:addVelocity(0, Gravity * dt)
	end
	for _,o in ipairs(Game.actives) do
		o:onUpdate(dt)
	end
	for _,o in ipairs(Game.collidable) do
	end
end

function love.draw()
	for _,drawable in ipairs(Game.drawables) do
		drawable:onDraw()
	end
end

function love.quit()
	love.event.quit()
end

love.run()
