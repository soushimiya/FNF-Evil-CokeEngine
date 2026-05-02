texture = "res://game/characters/BOYFRIEND"
position = Vector2(0, 0)
camera_position = Vector2(0, -50)

animations = {
	{
		name = "idle",
		prefix = "BF idle dance",
		offset = Vector2(0, -5),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_left",
		prefix = "BF NOTE LEFT",
		offset = Vector2(-20, -2),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_down",
		prefix = "BF NOTE DOWN",
		offset = Vector2(0, 20),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_up",
		prefix = "BF NOTE UP",
		offset = Vector2(25, -20),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_right",
		prefix = "BF NOTE RIGHT",
		offset = Vector2(45, 0),
		indices = {},
		loop = false,
		fps = 24
	},

	{
		name = "sing_lef_tmiss",
		prefix = "BF NOTE LEFT MISS",
		offset = Vector2(-20, -15),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_dow_nmiss",
		prefix = "BF NOTE DOWN MISS",
		offset = Vector2(0, 1),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_u_pmiss",
		prefix = "BF NOTE UP MISS",
		offset = Vector2(20, -15),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "sing_righ_tmiss",
		prefix = "BF NOTE RIGHT MISS",
		offset = Vector2(40, -10),
		indices = {},
		loop = false,
		fps = 24
	},

	{
		name = "death",
		prefix = "BF dies",
		offset = Vector2(-12, 7),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "death_loop",
		prefix = "BF Dead Loop",
		offset = Vector2(-12, 8),
		indices = {},
		loop = true,
		fps = 24
	},
	{
		name = "death_confirm",
		prefix = "BF Dead confirm",
		offset = Vector2(-12, -24),
		indices = {},
		loop = false,
		fps = 24
	}
}

scale = 1
antialiasing = true
flip_horizon = true

icon = "bf"
health_color = Color(49, 176, 209)

vocal_prefix = "bf"
