extends FNFScene2D

@export var song_list:Array[FNFSong] = []

@onready var items_y = $items.global_position.y

var target_score:int = 0
var score_lerp:int = 0

var target_accuracy:float = 0
var accuracy_lerp:float = 0

var current_item:int = 0:
	set(value):
		
		GlobalSound.play_sound("menu/scroll")
		current_item = wrap(value, 0, song_list.size())
		GlobalSound.play_music_raw(preview_musics[current_item])

		var before_difficulties = difficulties
		difficulties = song_list[current_item].difficulties
		if difficulties.has(before_difficulties[current_difficulty]):
			current_difficulty = difficulties.find(before_difficulties[current_difficulty])
		else:
			if difficulties.has("normal"):
				current_difficulty = 1 # normal
			else:
				current_difficulty = 0
var controllable:bool = true

var difficulties:Array = []
var current_difficulty:int = 0:
	set(value):
		GlobalSound.play_sound("menu/scroll")
		current_difficulty = value
		current_difficulty = wrap(current_difficulty, 0, difficulties.size())

var preview_musics:Array = []

static var current_item_save:int = 0

func _ready() -> void:
	DiscordData.set_rpc("In Freeplay Menu")

	for i in song_list.size():
		var lab = SparrowLabel.new()
		lab.font_size = 1.08
		lab.frames = preload("res://core/fonts/alphabet/bold.xml")
		lab.text = song_list[i].display_name.to_upper()
		$items.add_child(lab)
		lab.position.y = 130*i

		preview_musics.push_back(song_list[i].instrumental)

	difficulties = song_list[0].difficulties
	current_item = current_item_save
			
func _process(delta: float) -> void:
	current_item_save = current_item
	if Input.is_action_just_pressed("ui_up") && controllable:
		current_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		current_item += 1
		
	if Input.is_action_just_pressed("ui_left") && controllable:
		current_difficulty -= 1
	elif Input.is_action_just_pressed("ui_right") && controllable:
		current_difficulty += 1
	
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		GlobalSound.stop_music()
		controllable = false
		
		# ok starting song lol
		PlayScene.playlist = [song_list[current_item]]
		PlayScene.difficulty = difficulties[current_difficulty]
		PlayScene.play_mode = PlayScene.PlayMode.FREEPLAY
		Main.switch_scene(load("res://game/play_scene/play_scene.tscn"))
	if Input.is_action_just_pressed("ui_exit") && controllable:
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		Main.switch_scene(load("res://menus/main_menu/main_menu.tscn"))
		
	$items.global_position.y = lerpf($items.global_position.y, items_y - $items.get_children()[current_item].position.y, 0.02)
	
	for i in song_list.size():
		if i == current_item:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5

	if SaveData.data["_score"].has(song_list[current_item].id + "-" + difficulties[current_difficulty]):
		var saved_score = SaveData.data._score[song_list[current_item].id + "-" + difficulties[current_difficulty]]
		target_score = saved_score.score
		target_accuracy = saved_score.accuracy
	else:
		target_score = 0
		target_accuracy = 0
		
	var lerp_size = 0.01
	score_lerp = lerp(score_lerp, target_score, lerp_size)
	accuracy_lerp = lerp(accuracy_lerp, target_accuracy, lerp_size)
	
	$score_label.text = "PERSONAL BEST: " + str(score_lerp) + " (" + str(snapped(accuracy_lerp, 0.01)) + "%)"
	var left_arrow = "< "
	var right_arrow = " >"
	if difficulties.size() < 2:
		left_arrow = "[color=GRAY]< [/color]"
		right_arrow = "[color=GRAY] >[/color]"
	$diff_label.text = left_arrow + difficulties[current_difficulty].to_upper() + right_arrow
