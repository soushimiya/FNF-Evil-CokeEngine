extends Node2D

var cur_volume:int = 10

@onready var base_pos = Vector2(position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var remapped_volume = int(remap(AudioServer.get_bus_volume_db(0), -80, 0, 0, 10))
	if Input.is_action_just_pressed("volume_up"):
		remapped_volume += 1
	elif Input.is_action_just_pressed("volume_down"):
		remapped_volume -= 1
	if remapped_volume > 10:
		remapped_volume = 10
	elif remapped_volume < 0:
		remapped_volume = 0
	if cur_volume != remapped_volume:
		display_tray()
		if remapped_volume == 10:
			GlobalSound.play_sound("soundtray/vol_max")
		elif cur_volume > remapped_volume:
			GlobalSound.play_sound("soundtray/vol_up")
		elif cur_volume < remapped_volume:
			GlobalSound.play_sound("soundtray/vol_up")
		cur_volume = remapped_volume
		if cur_volume != 0:
			$bars.visible = true
			$bars.texture = load("res://game/play_ui/assets/soundtray/bars_" + str(cur_volume) + ".png")
		else:
			$bars.visible = false
		AudioServer.set_bus_volume_db(0, remap(cur_volume, 0, 10, -80, 0))
		SaveData.data._volume = cur_volume


func display_tray():
	$hide_timer.stop()
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(base_pos.x, base_pos.y + 110), 1)
	$hide_timer.start()

func _on_hide_timer_timeout() -> void:
	var tween_end = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_end.tween_property(self, "position", base_pos, 0.5)
