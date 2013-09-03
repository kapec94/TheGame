Fonts = {
	file_cache = {};
	font_cache = {};

	get = function (name, size)
		assert (name ~= nil)
		assert (tonumber(size) ~= nil)

		local font_name = name .. '$' .. tostring(size)
		local font = Fonts.font_cache[font_name]

		dbg ('Loading font ' .. font_name)

		if font == nil then
			dbg ('Caching font object.')

			local file_data = Fonts.file_cache[name]
			if file_data == nil then
				local path = string.format('res/%s.ttf', name)
				dbg ('Caching font file ' .. path)
				assert (love.filesystem.exists(path))

				local file = love.filesystem.newFile(path)
				file:open('r')
				file_data = love.filesystem.newFileData(file:read(), path)
				Fonts.file_cache[name] = file_data
			end
			font = love.graphics.newFont(file_data, size)
			Fonts.font_cache[font_name] = font
		end
		return font
	end;
}

