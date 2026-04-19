extends Node2D
class_name Main

const inital_scene = preload("res://menus/title_screen/intro_text.tscn")

static var default_trans_in = "grad_in"
static var default_trans_out = "grad_out"

static var next_trans_in = "quick_in"
static var next_trans_out = "grad_out"

static var scene:
	get():
		return instance.get_node("SceneLoader").get_child(0)

static var instance

static func switch_scene(scene):
	if instance != null:
		instance._switch_scene(scene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	DiscordData.init()
	SaveData.load()

	$overlay/Soundtray.cur_volume = SaveData.data._volume
	AudioServer.set_bus_volume_db(0, remap(SaveData.data._volume, 0, 10, -80, 0))
	match SaveData.data.vsync:
		_:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
			
	CokeUtil.set_mouse_visibility(false)
	
	_switch_scene(inital_scene)
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveData.save()

var old_mem = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$overlay/debug_text.text = "FPS: " + str(Engine.get_frames_per_second())
	if Engine.get_frames_per_second() < 30:
		$overlay/debug_text.text = '[color="red"]' + $overlay/debug_text.text + '[/color]'
	
	var memory_using = OS.get_static_memory_usage() / (1024 * 1024)
	if memory_using != old_mem:
		old_mem = memory_using
	var thing = "Memory: " + str(memory_using) +  " MB"
	if memory_using > 800:
		thing = '[color="red"]' + thing + '[/color]'
	$overlay/debug_text.text += "\n" + thing + '[color="gray"] / ' + str(old_mem) + ' MB[/color]'
	$overlay/debug_text.text += '\n[color="red"]Evil[/color] Coke Engine v' + ProjectSettings.get_setting("application/config/version")
	
	$overlay/debug_text_extra.text = "Total Object: " + str(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	$overlay/debug_text_extra.text += "\n_total Draw Calls (in Frame): " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	$overlay/debug_text_extra.text += "\n\n_audio Output Latency: " + str(AudioServer.get_output_latency() * 1000.0)
	
	# RELOADING SHIT
	if Input.is_action_just_pressed("hotreload"):
		next_trans_in = "quick_in"
		_switch_scene(next_state)
		
	match SaveData.data.debug_counter_type:
		0:
			$overlay/debug_text.visible = false
			$overlay/debug_text_extra.visible = false
		1:
			$overlay/debug_text.visible = true
			$overlay/debug_text_extra.visible = true
		2:
			$overlay/debug_text.visible = true
			$overlay/debug_text_extra.visible = false

var next_state
func _switch_scene(scene):
	if scene != next_state:
		next_state = scene
	$Transition/animation.play(next_trans_in)

func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == next_trans_in:
		if $SceneLoader.get_children().size() > 0:
			$SceneLoader.get_child(0).queue_free()
		if $SubSceneLoader.get_children().size() > 0:
			$SubSceneLoader.get_child(0).queue_free()
		$SceneLoader.add_child(next_state.instantiate())
		$Transition/animation.play(next_trans_out)
		
		next_trans_in = default_trans_in
		next_trans_out = default_trans_out
