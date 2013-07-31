local Config = {
	Screen = {
		Width = 480,
		Height = 360
	},
	Gravity = vec(0, 1200),
	Resources = "res", -- NO FUCKING SLASH AT THE END
	MapPath = "/maps/",
	Font = "Ubuntu-R",
	Map = "test2",
	Debug = true
}

if not (love.filesystem.exists(Config.Resources) and love.filesystem.isDirectory(Config.Resources)) then
	error ('Path specified as Config.Resources doesn\'t exist!')
end

Config.resourcePath = function (relative_path)
	return Config.Resources .. '/' .. relative_path
end

return Config
