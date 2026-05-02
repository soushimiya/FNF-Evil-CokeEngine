extends FNFScene2D
class_name PlayScene

enum PlayMode
{
	STORY,
	FREEPLAY,
	CHARTER
}

static var instance:PlayScene

static var playlist:Array = []
static var song:FNFSong:
	get():
		if playlist.size() > 0:
			return playlist[0]
		else:
			return null

static var chart:
	get():
		if song != null:
			return song.charts[difficulty]
		else:
			return null
static var events:Array = []

static var level:String = ""
static var difficulty:String = "hard"
static var play_mode:PlayMode = PlayMode.FREEPLAY

var stage = null

var dj = null
var player = null
var opponent = null
var extra_characters:Dictionary = {}

var cam_follow = Node2D.new()
var cam_follow_ext = Node2D.new()
var cam_zoom:float = 0.7
var cam_zoom_add:float = 0
var cam_zoom_mult:float = 1

var camera_bop_rate:int = 4

var on_countdown:bool = false
var song_started:bool = false

static var static_stat:Dictionary

var health:float = 1:
	set(value):
		if value > 2:
			value = 2
		health = value
		if health <= 0:
			if health < 0:
				health = 0
			death()
		return value
var misses:int = 0
var score:float = 0

var accuracy:float = 100
var every_note:float = 0
var hit_note_diffs:float = 0

var combo:int = -1:
	set(value):
		combo = value
		if combo > max_combo:
			max_combo = combo
var max_combo:int = 0
var combo_breaks:int = 0

var scroll_speed_mult:float = 1

var modchart:ModchartManager
var modules:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	GlobalSound.stop_music()
	CokeUtil.set_mouse_visibility(false)

	if static_stat == null || static_stat == {}:
		static_stat = {"score": 0, "misses": 0, "accuracy": 0}
	events = song.events.duplicate(true)
	
	$inst.stream = song.instrumental
	$player_voices.stream = song.player_vocals
	$opponent_voices.stream = song.opponent_vocals
		
	conductor.bpm = chart.bpm
	conductor.map_bpm_changes(song)
	
	DiscordData.set_rpc("Playing " + song.display_name + " (" + difficulty + ")")
	
	$hud/play_ui.game = instance
	
	$hud/opponent_strums.botplay = true
	$hud/player_strums.botplay = true
	$hud/player_strums.play_note_splash = true
	
	$hud/player_strums.note_hit.connect(good_note_hit)
	$hud/player_strums.note_miss.connect(note_miss_callback)
	if !SaveData.data.ghost_tap:
		$hud/player_strums.ghost_tapped.connect(func(i): note_miss(i, 0.02, player))
	$hud/opponent_strums.note_hit.connect(opponent_note_hit)
	
	if SaveData.data.downscroll:
		for lane in [$hud/opponent_strums, $hud/player_strums]:
			lane.downscroll = true
			lane.position.y += 530
	
	# pushing notes
	for opponent_note in chart.opponent.notes:
		var raw_data = {
			"strum_time": opponent_note.time,
			"note_data": int(opponent_note.id),
			"sustain_length": opponent_note.length
		}
		$hud/opponent_strums.add_note_data(raw_data)

	for player_note in chart.player.notes:
		var raw_data = {
			"strum_time": player_note.time,
			"note_data": int(player_note.id),
			"sustain_length": player_note.length
		}
		$hud/player_strums.add_note_data(raw_data)


	modchart = ModchartManager.new()
	add_child(modchart)
	$hud/player_strums.post_update_note.connect(func(): update_modchart(0))
	$hud/opponent_strums.post_update_note.connect(func(): update_modchart(1))
	
	if SaveData.data.middlescroll:
		modchart.set_percent("opponent", 50)
		$hud/opponent_strums.visible = false

	# init stages
	var target_stage = chart.stage
	if !ResourceLoader.exists("res://game/stages/" + target_stage + ".tscn") && !list_stage_script().has(target_stage):
			target_stage = "Stage"

	if list_stage_script().has(target_stage):
		stage = preload("res://game/stages/lua_script_stage.tscn").instantiate()
		
		var lua_script = LuaModule.new("stages/" + target_stage)
		add_lua_variables(lua_script)
		
		lua_script.lua.globals["stage"] = stage
		lua_script.lua.globals["player_pos"] = stage.get_node("player_pos")
		lua_script.lua.globals["opponent_pos"] = stage.get_node("opponent_pos")
		lua_script.lua.globals["dj_pos"] = stage.get_node("dj_pos")
		
		lua_script.do()
		modules["_stage_"] = lua_script
		lua_script.call_lua("build")
	else:
		stage = load("res://game/stages/" + target_stage + ".tscn").instantiate()
	add_child(stage)
	
	dj = FNFCharacter2D.new(chart.dj.character)
	add_child(dj)
	player = FNFCharacter2D.new(chart.player.character)
	add_child(player)
	player.flip_h = !player.flip_h
	opponent = FNFCharacter2D.new(chart.opponent.character)
	add_child(opponent)
	
	dj.idle()
	player.idle()
	opponent.idle()
	
	# stage var shit
	cam_zoom = stage.zoom
	
	stage.init_characters()
	
	for file in list_global_script():
		var lua_script = LuaModule.new("global/" + file)
		add_lua_variables(lua_script)
		lua_script.do()
		modules[file] = lua_script
		lua_script.call_lua("on_ready")
	
	start_countdown()

var cur_countdown:int = 0
func start_countdown():
	$hud/play_ui.init_hud()
	on_countdown = true
	conductor.song_position = 0
	conductor.song_position -= conductor.crotchet * 5
	
	var countdown_timer = Timer.new()
	
	add_child(countdown_timer)
	countdown_timer.timeout.connect(func():
		var count_sprite = Sprite2D.new()
		count_sprite.scale = Vector2(0.52, 0.52)
		var spr_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		spr_tween.tween_property(count_sprite, "modulate", Color.TRANSPARENT, conductor.crotchet / 1000 *1.1)
		spr_tween.tween_property(count_sprite, "scale", Vector2(0.5, 0.5), conductor.crotchet / 1000)
		$hud/countdown_spawner.add_child(count_sprite)
		
		match cur_countdown:
			0:
				GlobalSound.play_sound("countdown/onyourmark")
				count_sprite.texture = load("res://game/ui/assets/countdown/onyourmark.png")
				
				player.idle()
				opponent.idle()
			1:
				GlobalSound.play_sound("countdown/ready")
				count_sprite.texture = load("res://game/ui/assets/countdown/ready.png")
			2:
				GlobalSound.play_sound("countdown/set")
				count_sprite.texture = load("res://game/ui/assets/countdown/set.png")
				
				player.idle()
				opponent.idle()
			3:
				GlobalSound.play_sound("countdown/go")
				count_sprite.texture = load("res://game/ui/assets/countdown/go.png")
			4:
				countdown_timer.stop()
				$hud/countdown_spawner.queue_free()
				on_countdown = false
				start_song()
				
		dj.idle()

		cur_countdown += 1
	)
	countdown_timer.start(conductor.crotchet / 1000)
	for lua in modules.values(): lua.call_lua("on_start_countdown")
	for event in events:
		if event.time == 0 && event.name == "Move Camera":
			call_event(event.name, event.data)
			events.erase(event)
	
func start_song():
	song_started = true
	$inst.play()
	$player_voices.play()
	$opponent_voices.play()
	
	conductor.song_position = 0
	for lua in modules.values(): lua.call_lua("on_song_start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !song_started:
		conductor.song_position += delta * 1000
	else:
		var inst_time = $inst.get_playback_position() + AudioServer.get_time_since_last_mix()
		conductor.song_position = inst_time * 1000
		for event in events:
			if  conductor.song_position >= event.time:
				call_event(event.name, event.data)
				events.erase(event)

	# Peak absolutely cinema guys
	$camera.global_position = cam_follow.global_position + cam_follow_ext.global_position
	cam_zoom_add = lerpf(0, cam_zoom_add, exp(-delta * 6.25))
	$camera.zoom.x = (cam_zoom * cam_zoom_mult) + cam_zoom_add
	$camera.zoom.y = $camera.zoom.x
	$hud.scale.x = 1 + cam_zoom_add
	$hud.scale.y = $hud.scale.x
	# terrible fix of canvaslayer offsetting
	$hud.offset.x = (-Constant.width/2)*($hud.scale.x-1)
	$hud.offset.y = (-Constant.height/2)*($hud.scale.y-1)
	
	if every_note < 1:
		accuracy = 0
	else:
		accuracy = (hit_note_diffs / every_note)*100
	
	if Input.is_action_just_pressed("ui_accept"):
		Main.instance.get_node("SubSceneLoader").add_child(load("res://game/play_scene/pause_screen.tscn").instantiate())
		self.process_mode = Node.PROCESS_MODE_DISABLED

	if Input.is_action_just_pressed("ui_debug2"):
		Main.next_trans_in = "quick_in"
		if Input.is_key_pressed(KEY_SHIFT):
			CharacterDebug.character_name = player.character_name
			CharacterDebug.player = true
		else:
			CharacterDebug.character_name = opponent.character_name
			CharacterDebug.player = false
		Main.switch_scene(preload("res://menus/debug/character_debug.tscn"))
	if Input.is_action_just_pressed("kill"):
		self.health = 0
		
	$hud/opponent_strums.scroll_speed = chart.scroll_speed * scroll_speed_mult
	$hud/player_strums.scroll_speed = chart.scroll_speed * scroll_speed_mult
		
	for lua in modules.values(): lua.call_lua("on_process", [delta])

func beat_hit(beat):
	dj.idle()
	if beat % 2 == 0:
		player.idle()
		opponent.idle()
	if beat % camera_bop_rate == 0:
		cam_zoom_add = 0.025
	$hud/play_ui.beat_hit(beat)
	for lua in modules.values(): lua.call_lua("on_beat_hit", [beat])

func good_note_hit(note, is_sustain):
	for lua in modules.values(): lua.call_lua("on_good_note_hit", [note, is_sustain])
	
	$player_voices.volume_db = 0
	do_sing_animation(player, note.note_data)
	
	if !is_sustain:
		every_note += 1
		var data = RatingData.judgements[RatingData.get_rating_name(note.hit_diff)]

		score += 350*data.score_mult
		health += 0.03
		hit_note_diffs += data.accuaracy_mult
		combo += 1
		
		spawn_judgement_sprite(RatingData.get_rating_name(note.hit_diff))
	else:
		score += 0.1

func note_miss_callback(note, is_sustain):
	$player_voices.volume_db = -80
	if is_sustain:
		note_miss(note.note_data, 0.04, player)
	else:
		every_note += 1
		note_miss(note.note_data, 0.08, player)

func note_miss(id:int = 0, health_loss:float = 1, character = null):
	misses += 1
	health -= health_loss

	if combo > -1:
		combo = -1
		combo_breaks += 1
	
	var rng = RandomNumberGenerator.new()
	GlobalSound.play_sound("missnote" + str(rng.randi_range(1, 3)))
	if character != null:
		do_sing_animation(character, id, "miss")

func opponent_note_hit(note, is_sustain):
	for lua in modules.values(): lua.call_lua("on_opponent_note_hit", [note, is_sustain])
	do_sing_animation(opponent, note.note_data)

var anim_array = ["sing_left", "sing_down", "sing_up", "sing_right"]
func do_sing_animation(char:FNFCharacter2D, data:int, postfix:String = ""):
	if char.interruptible:
		char.play_anim(anim_array[data] + postfix, true)

var camera_target:String = "player"
const default_camera_trans = Tween.TRANS_EXPO
const default_camera_ease = Tween.EASE_OUT

func move_camera(position:Vector2, speed:float = 1.9, trans:Tween.TransitionType = default_camera_trans, ease:Tween.EaseType = default_camera_ease):
	var cam_follow_tween = get_tree().create_tween()
	cam_follow_tween.set_trans(trans).set_ease(ease)
	cam_follow_tween.tween_property(cam_follow, "position", position, speed)

func move_camera_extend(position:Vector2, speed:float = 1.4, trans:Tween.TransitionType = default_camera_trans, ease:Tween.EaseType = default_camera_ease):
	var cam_follow_ext_tween = get_tree().create_tween()
	cam_follow_ext_tween.set_trans(trans).set_ease(ease)
	cam_follow_ext_tween.tween_property(cam_follow_ext, "position", position, speed)


func spawn_judgement_sprite(judge:String):
	var judge_spawner = $hud/judge_spawner
	var judge_world = stage.judge_spawner
	if (judge_world != null): #&& world_judge_display
		judge_spawner = judge_world

	var judge_sprite = Sprite2D.new()
	judge_sprite.scale = Vector2(1.15, 1.15)
	judge_sprite.texture = load("res://game/ui/assets/judgements/" + judge + ".png")
	judge_spawner.add_child(judge_sprite)

	var spr_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	spr_tween.finished.connect(func(): judge_sprite.queue_free())
	spr_tween.tween_property(judge_sprite, "scale", Vector2(1, 1), (conductor.crotchet / 1000))
	spr_tween.tween_property(judge_sprite, "modulate", Color.TRANSPARENT, (conductor.crotchet / 1000)*2)
	spr_tween.tween_property(judge_sprite, "position:y", judge_sprite.position.y + 140, (conductor.crotchet / 1000)*2.3)

	if combo > 0:
		var combo_display = preload("res://game/ui/combo_display.tscn").instantiate()
		combo_display.scale = Vector2(0.8, 0.8)
		combo_display.number = self.combo
		combo_display.global_position = Vector2(judge_sprite.global_position.x, judge_sprite.global_position.y + 200)
		judge_spawner.add_child(combo_display)
		
		spr_tween.finished.connect(func(): combo_display.queue_free())
		spr_tween.tween_property(combo_display, "scale", Vector2(0.75, 0.75), (conductor.crotchet / 1000))
		spr_tween.tween_property(combo_display, "modulate", Color.TRANSPARENT, (conductor.crotchet / 1000)*3)
		spr_tween.tween_property(combo_display, "position:y", combo_display.position.y + 50, (conductor.crotchet / 1000)*3)

func list_global_script() -> Array:
	var final_array = []
	if DirAccess.dir_exists_absolute("res://game/scripts/global"):
		var files = DirAccess.get_files_at("res://game/scripts/global/")
		for file in files:
			if file.ends_with(".lua"):
				final_array.push_back(file.split(".lua")[0])
	return final_array
	
func list_stage_script() -> Array:
	var final_array = []
	if DirAccess.dir_exists_absolute("res://game/stages/"):
		var files = DirAccess.get_files_at("res://game/stages/")
		for file in files:
			if file.ends_with(".lua"):
				final_array.push_back(file.split(".lua")[0])
	return final_array

static func add_lua_variables(module:LuaModule):
	module.lua.globals["game"] = PlayScene.instance
	module.lua.globals["modchart"] = PlayScene.instance.modchart
	
	module.lua.globals["add_stage_sprite"] = func(obj): PlayScene.instance.stage.add_child(obj)
	module.lua.globals["add_hud_sprite"] = func(obj): PlayScene.instance.get_node("hud").add_child(obj)
	
	# h,s,v,b
	module.lua.globals["set_hsv_adjust"] = func(obj, h:float = 0, s:float = 1, v:float = 1, b:float = 0):
		obj.material = ShaderMaterial.new()
		obj.material.shader = preload("res://core/shaders/hsv_adjust.gdshader")
		
		obj.material.set_shader_parameter("hue_shift", h)
		obj.material.set_shader_parameter("saturation_mult", s)
		obj.material.set_shader_parameter("value_mult", v)
		obj.material.set_shader_parameter("brightness_add", b)

func update_modchart(player:int):
	var target = $hud/opponent_strums
	if player == 0:
		target = $hud/player_strums

	for i in target.strums.size():
		modchart.update_strum(target, i, player)
	for note in target.get_node("note_spawner").get_children():
		modchart.update_note(note, player)

# ending song stuff
func _on_inst_finished() -> void:
	# continue to next song
	static_stat["score"] += self.score
	static_stat["misses"] += self.misses
	static_stat["accuracy"] += self.accuracy
	if static_stat["accuracy"] > 100:
		static_stat["accuracy"] = 100
		
	if playlist.size() > 1:
		playlist.pop_front()
		Main.next_trans_in = "quick_in"
		Main.next_trans_out = "quick_out"
		Main.switch_scene(preload("res://game/play_scene/play_scene.tscn"))
	else:
		match play_mode:
			PlayMode.FREEPLAY:
				var replace:bool = true
				if SaveData.data._score.has(song.id + "-" + difficulty):
					var og_data = SaveData.data._score[song.id + "-" + difficulty]
					if og_data.score < static_stat.score:
						replace = false
				if replace:
					SaveData.data._score[song.id + "-" + difficulty] = static_stat
				Main.switch_scene(load("res://menus/freeplay/freeplay.tscn"))
			PlayMode.STORY:
				SaveData.data._score["story_" + level] = static_stat
				Main.switch_scene("MainMenuState")
			PlayMode.CHARTER:
				Main.switch_scene("MainMenuState")
		static_stat = {}

var died:bool = false
# haha funny thing lmfao
func death():
	if died:
		return
	died = true

	$hud.visible = false #grrr kys kys kys
	var thing = load("res://game/play_scene/game_over_screen.tscn").instantiate()
	thing.global_position = self.player.global_position
	add_child(thing)
	self.process_mode = Node.PROCESS_MODE_DISABLED

	DiscordData.set_rpc("Game Over - " + song.display_name + " (" + difficulty + ")")

func call_event(name:String, data:Dictionary):
	for lua in modules.values(): lua.call_lua("on_call_event", [name, data])
	
	match name:
		"Move Camera":
			var target_pos = Vector2.ZERO
			if data.has("position"):
				target_pos = Vector2(data.position[0], data.position[1])
			
			if data.has("target"):
				camera_target = data.target
				if data.target == "player":
					target_pos += player.position + player.camera_position + stage.player_camera_offset
				else:
					target_pos += opponent.position + opponent.camera_position + stage.opponent_camera_offset

			var trans = default_camera_trans
			if data.has("trans"):
				trans = data.trans
			var ease = default_camera_ease
			if data.has("ease"):
				ease = data.ease
			var speed = 1.9
			if data.has("speed"):
				speed = conductor.step_crotchet * data.speed / 1000
			move_camera(target_pos, speed, trans, ease)
		"Zoom Camera":
			var target_zoom = 1;
			if data.has("value"):
				target_zoom = data.value

			if data.has("speed"):
				var trans = default_camera_trans
				if data.has("trans"):
					trans = data.trans
				var ease = default_camera_ease
				if data.has("ease"):
					ease = data.ease

				var zoom_mult_tween = get_tree().create_tween()
				zoom_mult_tween.set_trans(trans).set_ease(ease)
				zoom_mult_tween.tween_property(self, "cam_zoom_mult", target_zoom, conductor.step_crotchet * data.speed / 1000)
			else:
				cam_zoom_mult = target_zoom
		"Set Camera Bop Rate":
			camera_bop_rate = int(data.value)
		"Change Scroll Speed":
			if data.has("speed"):
				var scroll_tween = get_tree().create_tween()
				
				if data.has("trans"):
					scroll_tween.set_trans(data.trans)
				if data.has("ease"):
					scroll_tween.set_ease(data.ease)

				scroll_tween.tween_property(self, "scroll_speed_mult", data.value, conductor.step_crotchet * data.speed / 1000)
			else:
				scroll_speed_mult = data.value
		"Play Animation":
			var target
			match(data.target.to_lower()):
				"player":
					target = player
				"opponent":
					target = opponent
				"dj":
					target = dj
				_:
					target = extra_characters.get(data.target, opponent)
			
			target.play_anim(data.animation, data.has("force") && data.force)
