extends Node2D

var item_list = [
	"Resume",
	"Restart Song",
	"Options",
	"Exit Song"
]

const item_list_debug = [
	"Resume",
	"Restart Song",
	"Options",
	"Toggle Botplay",
	"Exit Song",
	#"Back Charter"
]

var debug:bool = true
var cur_item:int = 0
var items_y = 0
var controllable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if debug:
		item_list = item_list_debug
	GlobalSound.play_music("breakfast")
	GlobalSound.music_player.volume_db = -80
	
	GlobalSound.play_sound("menu/scroll")
	for i in item_list.size():
		var lab = SparrowLabel.new()
		lab.font_size = 1.08
		lab.frames = preload("res://game/play_ui/assets/fonts/bold.xml")
		lab.text = item_list[i].to_upper()
		$items.add_child(lab)
		lab.position.y = 130*i
	items_y = $items.global_position.y
	
	$song.text = PlayScene.song.display_name
	$meta.text = "Composed by: " + PlayScene.song.artist + "\n_charted by: " + PlayScene.song.charter
	$extra.text = "\n"+PlayScene.song.extra_description

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && controllable:
		GlobalSound.play_sound("menu/scroll")
		cur_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		GlobalSound.play_sound("menu/scroll")
		cur_item += 1
	elif Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.stop_music()
		GlobalSound.music_player.volume_db = 0.0
		controllable = false
		select_item(item_list[cur_item])
	if Input.is_action_just_pressed("ui_exit") && controllable:
		resume()
		
	cur_item = wrap(cur_item, 0, item_list.size())

	for i in item_list.size():
		if i == cur_item:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5
	$items.global_position.y = lerpf($items.global_position.y, items_y - $items.get_children()[cur_item].position.y, 0.02)
	# im too lazy to doing tweens sorry
	GlobalSound.music_player.volume_db = lerpf(GlobalSound.music_player.volume_db, 0.0, 0.004)

func select_item(item):
	match item:
		"Resume":
			resume()
		"Restart Song":
			Main.switch_scene(load("res://game/play_scene/play_scene.tscn"))
		"Options":
			OptionMenu.back_to_game = true
			Main.switch_scene(load("res://menus/options/option_menu.tscn"))
		"Exit Song":
			match PlayScene.instance.play_mode:
				PlayScene.PlayMode.STORY:
					Main.switch_scene(load("res://menus/story_mode/story_mode.tscn"))
				_:
					Main.switch_scene(load("res://menus/freeplay/freeplay.tscn"))
		"Toggle Botplay":
			PlayScene.instance.get_node("hud/player_strums").botplay = !PlayScene.instance.get_node("hud/player_strums").botplay
			resume()
		"Back Charter":
			Main.switch_scene(load("res://menus/debug/chart_editor.tscn"))

func resume():
	PlayScene.instance.process_mode = Node.PROCESS_MODE_INHERIT
	self.queue_free()
