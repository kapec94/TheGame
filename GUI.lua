GUI = {
	DebugInfo = {
		info = {
			{ 'FPS', love.timer.getFPS },
			{ 'me.v', function () return Game.me.v end },
			{ 'me.pos', function () return vec(Game.me.x, Game.me.y) end },
			{ 'falling', function () return Game.me.falling end }
		};

		init = function (self)
			Game:registerObject(self)
		end;

		show = function (self, layer)
			Game:addDrawable(self, layer)
		end;

		hide = function (self)
			Game:removeDrawable(self)
		end;

		onDraw = function (self)
			love.graphics.push()
			love.graphics.setColor(Colors.orange)

			local msg = ''
			for _, i in ipairs(self.info) do
				msg = msg .. string.format("%s: %s\n", i[1], tostring(i[2]()))
			end

			love.graphics.print(msg, 10, 10)
			love.graphics.pop()
		end;
	};

	DebugEventRenderer = {
		Color = { 255, 255, 255, 100 };

		init = function (self, map)
			assert (map)

			Game:registerObject(self)
			self.font = Fonts.get(Config.Font, 12)
			self.map = map
		end;

		show = function (self, layer)
			Game:addDrawable(self, layer)
		end;

		hide = function (self)
			Game:removeDrawable(self)
		end;

		onDraw = function (self)
			local old_font = love.graphics.getFont()

			love.graphics.setColor(self.Color)
			love.graphics.setFont(self.font)

			for name, e in pairs (self.map.events) do
				love.graphics.rectangle('line', e.x, e.y, e.width, e.height)
				love.graphics.print(name, e.x + 5, e.y - 18)
			end

			love.graphics.setFont(old_font)
		end;
	};

	HintButton = {
		Size = 40;
		Margin = 10;
		FontSize = 40;

		active = false;

		init = function (self)
			self.font = Fonts.get(Config.Font, self.FontSize)
			self.active = false
			self.message = nil
			self.x = love.graphics.getWidth() - self.Size - self.Margin
			self.y = self.Margin

			Game:registerObject(self)
		end;

		setActive = function (self, active)
			if active == nil then active = true end
			if active ~= self.active then
				if self.active == false then
					Game:addDrawable(self, 10)
					Game:addInteractive(self)
					self.active = true
				else
					Game:removeDrawable(self)
					Game:removeInteractive(self)
					self.active = false
				end
			end
		end;

		onKeyPress = function (self, key)
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and key == '/' then
				dbg ('Activated hint.')
				GUI.Message.showModalBox(self.message)
			end
		end;

		onDraw = function (self)
			local old_font = love.graphics.getFont()
			love.graphics.setFont(self.font)

			love.graphics.setColor(Colors.red)
			love.graphics.printf('?', self.x, self.y, self.Size, 'center')

			love.graphics.setFont(old_font)
		end;
	};

	Message = {
		Label = class {
			init = function (self)
				-- Those variables are to set by the user
				self.message = 'Label'
				self.x = 0
				self.y = 0
				self.font = Fonts.get('Ubuntu-R', 24)
				self.color = Colors.white

				self.visible = false
				self.layer = -1

				Game:registerObject(self)
			end;

			show = function (self, layer)
				if not self.visible then
					Game:addDrawable(self, layer)
					self.layer = layer
					self.visible = true
				elseif layer ~= self.layer then
					self:hide()
					self:show(layer)
				end
			end;

			hide = function (self)
				self.layer = -1
				self.visible = false
				Game:removeDrawable(self)
			end;

			onDraw = function (self)
				local font = love.graphics.getFont()
				love.graphics.setFont(self.font)
				love.graphics.setColor(self.color)

				love.graphics.push()
				love.graphics.translate(self.x, self.y)
				love.graphics.print(self.message, 0, 0)
				love.graphics.pop()

				love.graphics.setFont(font)
			end;
		};

		ModalBox = class {
			init = function (self)
				Game:registerObject(self)
				self.message = nil
			end;

			onDraw = function (self)
				local c = Colors.black
				local w, h = love.graphics.getWidth(), love.graphics.getHeight()
				love.graphics.setColor(c[1], c[2], c[3], 200)
				love.graphics.rectangle('fill', 0, 0, w, h)

				love.graphics.setColor(Colors.white)
				love.graphics.printf(self.message, 100, 100, w - 200)
			end;

			onKeyPress = function (self, key)
				if key == 'escape' then
					self:close()
				end
			end;

			close = function (self)
				dbg ('Modal box closing')
				self:onClose()
			end;

			onClose = function (self)
			end;
		};

		showModalBox = function (message)
			local box = GUI.Message.ModalBox()
			box.message = message

			box.onClose = function (self)
				Game:pause(false)
				Game:removeDrawable(self)
				Game:removeInteractive(self)
			end

			Game:pause()
			Game:addDrawable(box, 10)
			Game:addInteractive(box)
		end;
	}
}
