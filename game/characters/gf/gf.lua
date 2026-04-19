texture = "res://game/characters/gf/GF_assets"
position = Vector2(0, 0)
camera_position = Vector2(100, -100)

animations = {
    {
        name = "dance_left",
        prefix = "GF Dancing Beat",
        offset = Vector2(0, 0),
        indices = {30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        loop = false,
        fps = 24
    },
    {
        name = "dance_right",
        prefix = "GF Dancing Beat",
        offset = Vector2(0, 0),
        indices = {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29},
        loop = false,
        fps = 24
    }
}
idle_animations = {"dance_left", "dance_right"}

scale = 1
antialiasing = true
flip_horizon = false

icon = "gf"
health_color = Color(49, 176, 209)

vocal_prefix = "gf"