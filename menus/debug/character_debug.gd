extends FNFScene2D
class_name CharacterDebug

static var character_name = "dad"
static var player = false

var zoom_lerp = 1

var cur_anim_index:int = 0:
	set(value):
		cur_anim_index = value
		if cur_anim_index < 0:
			cur_anim_index = character.data.animations.size() - 1
		elif cur_anim_index > character.data.animations.size() - 1:
			cur_anim_index = 0
var ghost;
var character;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ghost = FNFCharacter2D.new(character_name)
	add_child(ghost)
	ghost.self_modulate = Color(0, 0, 0, 0.5)
	
	character = FNFCharacter2D.new(character_name)
	add_child(character)
	
	ghost.play_anim("idle")
	character.play_anim(character.data.animations[0].name)
	
	if player:
		ghost.flip_h = !ghost.flip_h
		character.flip_h = !character.flip_h
	
func _process(delta: float) -> void:
	$Camera2D.zoom.x = lerpf($Camera2D.zoom.x, zoom_lerp, 0.02)
	$Camera2D.zoom.y = $Camera2D.zoom.x
	
	$Camera2D.global_position = character.global_position
	var value = 1
	if Input.is_key_pressed(KEY_SHIFT):
		value = 10
	if Input.is_action_just_pressed("ui_left"):
		add_anim_offset(Vector2(-value, 0))
	if Input.is_action_just_pressed("ui_down"):
		add_anim_offset(Vector2(0, value))
	if Input.is_action_just_pressed("ui_up"):
		add_anim_offset(Vector2(0, -value))
	if Input.is_action_just_pressed("ui_right"):
		add_anim_offset(Vector2(value, 0))
		
	if Input.is_action_just_pressed("ui_accept"):
		character.play_anim(character.data.animations[cur_anim_index].name, true)
	if Input.is_action_just_pressed("ui_exit"):
		Main.next_trans_in = "quick_in"
		Main.switch_scene(load("res://game/play_scene/play_scene.tscn"))

	$overlay/debug_text.text = ""
	for anim in character.data.animations:
		if character.cur_anim == anim.name:
			$overlay/debug_text.text += ">"
		$overlay/debug_text.text += anim.name + "  offsets: " + "[" + str(anim.offset.x) + "," +  str(anim.offset.y) + "]\n"

func add_anim_offset(offset:Vector2):
	character.get_anim_data(character.cur_anim).offset += offset
	ghost.get_anim_data(character.cur_anim).offset += offset
	
	character.offset = character.get_anim_data(character.cur_anim).offset
	ghost.offset = ghost.get_anim_data(ghost.cur_anim).offset

# budddd
func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_W) and just_pressed:
		cur_anim_index -= 1
		character.play_anim(character.data.animations[cur_anim_index].name)
	if Input.is_key_pressed(KEY_S) and just_pressed:
		cur_anim_index += 1
		character.play_anim(character.data.animations[cur_anim_index].name)
	
	if Input.is_key_pressed(KEY_E) and just_pressed:
		zoom_lerp += 0.1
	if Input.is_key_pressed(KEY_Q) and just_pressed:
		zoom_lerp -= 0.1
