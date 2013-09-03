function love.conf(t)
	t.title = "The Game"
	t.author = "Mateusz Kapłon"
	t.url = "http://github.com/kapec94/TheGame"
	t.version = "0.8.0"

	t.console = true
	t.release = false

	t.screen.width = 480
	t.screen.height = 360

	t.modules.joystick = false
	t.modules.audio = false
	t.modules.sound = false
	t.modules.mouse = false
	t.modules.physics = false
end
