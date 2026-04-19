extends Node2D

@onready var strums = [$left, $down, $up, $right]
var spawn_distance:float = 3000
var queued_notes:Array = []

var strum_positions:Array = []

var scroll_speed:float = 1
# very funny implemetion but works so good im genious
var downscroll:bool = false:
	set(value):
		downscroll = value
		if downscroll:
			$note_spawner.scale.y = -1 # sustain auto fix lol
		else:
			$note_spawner.scale.y = 1
		strum_positions.clear()
		for i in strums.size():
			strum_positions.push_back(strums[i].position)
	
var botplay:bool = false
var play_note_splash:bool = false

var note_press_timer = [0, 0, 0, 0]
var control_array = ["note_left", "note_down", "note_up", "note_right"]

var default_anims = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"]
var press_anims = ["left press", "down press", "up press", "right press"]
var confirm_anims = ["left confirm", "down confirm", "up confirm", "right confirm"]

signal note_hit(note:Note, sustain:bool)
signal note_miss(note:Note, sustain:bool)

signal ghost_tapped(id:int)
signal post_update_note()

func add_note_data(raw:Dictionary) -> void:
	queued_notes.push_back(raw)
	queued_notes.sort_custom(func(a, b): return a.strum_time < b.strum_time)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	note_hit.connect(_noteHit)
	note_miss.connect(_noteMiss)
	downscroll = false # setter thing

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if queued_notes.size() > 0:
		var raw = queued_notes[0]
		# spawn note if in the spawn distance
		if raw.strum_time - PlayScene.instance.conductor.song_position < spawn_distance:
			var note = Note.new(raw.strum_time, raw.note_data, raw.sustain_length)
			$note_spawner.add_child(note)
			note.strumline = self
			queued_notes.erase(raw)
			
	# updating note pos & hit if this strumline on botplay
	for i in strum_positions.size():
		strums[i].position = strum_positions[i]
	for note in $note_spawner.get_children():
		if note.auto_follow:
			var target_x = strum_positions[note.note_data].x
			var target_y = strum_positions[note.note_data].y
			note.position.x = target_x
			#strum rotation do cool stuffs so i dont need to edit sustain shit yay!!
			note.position.y = target_y - (PlayScene.instance.conductor.song_position - note.strum_time) * (0.45 * scroll_speed)
			update_note_status(note)
		
		if botplay && PlayScene.instance.conductor.song_position >= note.strum_time && note.status == Note.HITTABLE:
			note.hit_diff = 0 # relly awrsome
			note_hit.emit(note, false)
			
	if !botplay:
		input_process(delta)
	for strum in strums.size():
		strum_play(strum, "default")

	post_update_note.emit()

# yoo guys guyz
func update_note_status(note:Note):
	if note.status == Note.HIT || note.status == Note.MISSED:
		return

	if note.strum_time > PlayScene.instance.conductor.song_position - Constant.note_safe_zone && note.strum_time < PlayScene.instance.conductor.song_position + Constant.note_safe_zone:
		note.status = Note.HITTABLE
	elif (note.strum_time < PlayScene.instance.conductor.song_position - Constant.note_safe_zone):
		note_miss.emit(note, false)
	else:
		note.status = Note.NEUTRAL

func _noteHit(note, is_sustain):
	note.status = Note.HIT

	if (!is_sustain):
		if play_note_splash:
			var splash = preload("res://game/notes/note_splash.tscn").instantiate()
			strums[note.note_data].add_child(splash)
			splash.start(note)
		if note.sustain_length > 0:
			strums[note.note_data].get_node("cover").start()
			note.auto_follow = false
			note.position.y = strum_positions[note.note_data].y
			# oh! worst take for sustain note! nice!
			note.self_modulate = Color.TRANSPARENT
		else:
			note.queue_free()
	else:
		if note.sustain.length <= 0.1:
			strums[note.note_data].get_node("cover").end(play_note_splash)
			note.queue_free()
			return
		
		note.position.x = strums[note.note_data].position.x
		if !botplay && !Input.is_action_pressed(control_array[note.note_data]):
			strums[note.note_data].get_node("cover").end()
			note_miss.emit(note, true)

	strum_play(note.note_data, "confirm")

func _noteMiss(note, is_sustain):
	note.status = Note.MISSED
	note.queue_free()

func input_process(delta:float):
	for i in control_array.size():
		if Input.is_action_just_pressed(control_array[i]):
			strum_play(i, "press")
			var has_hittable_note = false
			for note in $note_spawner.get_children():
				if note.status == Note.HITTABLE: has_hittable_note = true
			if !has_hittable_note && note_press_timer[i] == 0:
				ghost_tapped.emit(i)
			note_press_timer[i] = 1

	for i in note_press_timer.size():
		note_press_timer[i] -= delta*5
		if note_press_timer[i] < 0:
			note_press_timer[i] = 0

	var frame_directions = []
	for note in $note_spawner.get_children():
		if note.status == Note.HITTABLE && note_press_timer[note.note_data] > 0 && !frame_directions.has(note.note_data):
			note_press_timer[note.note_data] = 0
			frame_directions.push_back(note.note_data)
			note.hit_diff = PlayScene.instance.conductor.song_position - note.strum_time
			note_hit.emit(note, false)


func strum_play(id:int, anim_type:String = "default"):
	var target_strum = strums[id]
	match anim_type:
		"default":
			if (botplay && !target_strum.is_playing()) || (!botplay && !Input.is_action_pressed(control_array[id])):
				strums[id].play(default_anims[id])
		"press":
			if target_strum.animation == default_anims[id]:
				strums[id].play(press_anims[id])
		"confirm":
			strums[id].stop()
			strums[id].play(confirm_anims[id])
