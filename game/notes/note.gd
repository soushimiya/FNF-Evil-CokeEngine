extends AnimatedSprite2D
class_name Note

enum
{
	NEUTRAL,
	HITTABLE,
	HIT,
	MISSED
}

var strum_time:float = 0
var note_data:int = 0
var sustain_length:float = 0

var strumline;
var sustain;

var status = NEUTRAL
var auto_follow:bool = true # for sustain notes

var default_scale:float = 0.7
var z:float = 0

var splash:String = "note_splashes"

var hit_diff:float = 0:
	set(value):
		if value < 0:
			value *= -1
		hit_diff = value

func _init(time:float, id:int, sus_length:float) -> void:
	self.strum_time = time
	self.note_data = id
	self.sustain_length = sus_length

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_frames = load("res://game/ui/assets/NOTE_assets.xml")
	scale = Vector2(default_scale, default_scale)
	
	match note_data:
		0:
			play("purple")
		1:
			play("blue")
		2:
			play("green")
		3:
			play("red")
	self.position.y += 3000
	var sus_length_adjust = sustain_length / Main.scene.conductor.step_crotchet
	if(roundf(sus_length_adjust) > 0):
		var sustain_note = preload("res://game/notes/sustain_note.tscn").instantiate()
		sustain_note.parent_note = self
		sustain_note.length = sus_length_adjust
		self.add_child(sustain_note)
		sustain_note.update_anim()
		self.sustain = sustain_note
	else:
		sustain_length = 0


func _process(delta: float) -> void:
	if strumline != null:
		if strumline.downscroll:
			self.scale.y = default_scale*-1
		else:
			self.scale.y = default_scale
