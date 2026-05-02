texture = "res://game/characters/daddy_dearest"
position = Vector2(0, 0)
camera_position = Vector2(100, -100)

animations = {
	{
		name = "idle",
		prefix = "idle",
		offset = Vector2(0, 0),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_left",
		prefix = "sing_left",
		offset = Vector2(-20, -5),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_down",
		prefix = "sing_down",
		offset = Vector2(20, 15),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_up",
		prefix = "sing_up",
		offset = Vector2(-3, -25),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_right",
		prefix = "sing_right",
		offset = Vector2(20, -15),
		indices = {},
		loop = false,
		fps = 24
	}
}

scale = 1
antialiasing = true
flip_horizon = false

icon = "dad"
health_color = Color(49, 176, 209)

vocal_prefix = "bf"
