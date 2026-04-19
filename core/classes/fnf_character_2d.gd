extends AnimatedSprite2D
class_name FNFCharacter2D

var data = CharacterData.default_data
var character_name:String = ""

var camera_position = Vector2()
var icon = "bf"

var sing_duration:float = 4

var cur_anim:String = ""
var hold_timer:float = 0
var singing:bool = false
var interruptible:bool = true

var is_animate:bool = false
var animate_anim_data:Dictionary
var animate_sprite:AnimateSymbol

func _init(character:String):
	data = CharacterData.get_character(character)
	character_name = data.id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animate_path = data.texture + "/Animation.json"
	if (ResourceLoader.exists(animate_path) or FileAccess.file_exists(animate_path)):
		var folder = data.texture
			
		animate_sprite = AnimateSymbol.new()
		animate_sprite.atlas = folder
		add_child(animate_sprite)
	
		var tex = FileAccess.get_file_as_string(animate_path)
		var json = JSON.parse_string(tex)
		animate_anim_data = CokeUtil.parse_animate_timeline(json)
		is_animate = true
	else:
		sprite_frames = load(data.texture + ".xml")

	position = data.position
	camera_position = data.camera_position
	scale = Vector2(data.scale, data.scale)
	icon = data.icon
	if !data.antialiasing:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flip_h = data.flip_horizon
	sing_duration = data.sing_duration
	
	self.frame_changed.connect(on_frame_change)
	self.animation_finished.connect(on_animation_finish)
	
	if is_animate:
		animate_sprite.frame_changed.connect(on_frame_change)

func play_anim(name:String, force:bool = false):
	var anim = get_anim_data(name)
	if anim == null:
		print("Animation not Found: " + name)
		return
		
	if force:
		stop()

	cur_anim = name
	cur_frame_index = 0
	var thing = float(anim.fps) / 24
	if is_animate:
		animate_sprite.playing = true
		animate_sprite.frame = animate_anim_data.get(anim.prefix)[0]
	else:
		play(anim.prefix, thing)
	self.offset = Vector2(anim.offset.x, anim.offset.y)

	if (anim.name.begins_with("sing") && interruptible):
		hold_timer = 0
		singing = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (singing):
		hold_timer += delta

		var sing_time_sec:float = (Main.scene.conductor.step_crotchet*0.0011) * sing_duration
		if (hold_timer > sing_time_sec):
			singing = false
			hold_timer = 0

func get_anim_data(name:String):
	for entry in data.animations:
		if entry.name == name:
			return entry
	return null

var cur_idle:int = 0
func idle():
	if !singing:
		if cur_idle > data.idle_animations.size() - 1:
			cur_idle = 0
		play_anim(data.idle_animations[cur_idle])
		cur_idle += 1


var cur_frame_index = 0
var auto_changed:bool = false
func on_frame_change():
	if auto_changed:
		return
	var data = get_anim_data(cur_anim)
	
	if is_animate:
		if animate_sprite.frame > animate_anim_data.get(data.prefix)[1]:
			animate_sprite.frame = animate_anim_data.get(data.prefix)[1]
			on_animation_finish()
	else:
		if data.indices.size() > 0:
			cur_frame_index += 1
			if cur_frame_index >= data.indices.size() - 1:
				cur_frame_index = data.indices.size() - 1

			auto_changed = true
			frame = data.indices[cur_frame_index]
			auto_changed = false

func on_animation_finish():
	var data = get_anim_data(cur_anim)
	if data.loop:
		play_anim(cur_anim)
	elif is_animate:
		animate_sprite.playing = false
