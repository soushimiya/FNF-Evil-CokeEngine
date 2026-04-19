extends Node2D
class_name GameOverScreen

static var character:String = "bf"

var loop_music:AudioStream = preload("res://core/audio/music/game_over.ogg")
var char:FNFCharacter2D = FNFCharacter2D.new(character)
var controllable:bool = true

func _ready() -> void:
	add_child(char)
	char.flip_h = !char.flip_h
	GlobalSound.play_sound("fnf_loss_sfx")
	char.play_anim("death")
	
	# buddy....... what the fuck??????
	var char_tween = get_tree().create_tween().set_parallel()
	char_tween.set_trans(PlayScene.default_camera_trans).set_ease(PlayScene.default_camera_ease)
	char_tween.tween_property(char, "global_position", Vector2(-200, 200), 5)
	var thing = 1 + (1 - PlayScene.instance.cam_zoom)
	char_tween.tween_property(char, "scale", Vector2(thing, thing), 5)

	$funny_timer.start()
	
func _on_funny_timer_timeout() -> void:
	GlobalSound.play_music_raw(loop_music)
	char.play_anim("death_loop", true)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") && controllable:
		$funny_timer.stop()
		char.play_anim("death_confirm", true)
		GlobalSound.play_music("game_over_end")
		$retry_timer.start()
		controllable = false
	if Input.is_action_just_pressed("ui_exit") && controllable:
		pass


func _on_retry_timer_timeout() -> void:
	Main.switch_scene(load("res://game/play_scene/play_scene.tscn"))
