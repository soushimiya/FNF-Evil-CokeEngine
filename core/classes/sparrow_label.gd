extends Node2D
class_name SparrowLabel

@export var text:String = "":
	set(value):
		text = value
		for i in text.length():
			var cur_str = text.substr(i, 1)
			if cur_str == " ":
				continue
		
			var spr = AnimatedSprite2D.new()
			spr.sprite_frames = frames
			spr.speed_scale = 0.5
			spr.scale = Vector2(font_size, font_size)
			if spr.sprite_frames.has_animation(cur_str):
				spr.play(cur_str)
				spr.animation_finished.connect(func(): spr.play(cur_str))
			else:
				spr.visible = false
			self.add_child(spr)
			spr.position.x = texture_width*(i*(font_size/1))

@export var frames:SpriteFrames
@export var texture_width:int = 50
@export var font_size:float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
