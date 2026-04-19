extends Node2D
class_name FNFStage2D

@export var zoom:float = 1
@export var camera_speed:float = 1.9
@export var hide_gf:bool = false

@export var player_camera_offset:Vector2 = Vector2()
@export var opponent_camera_offset:Vector2 = Vector2()

var judge_spawner:Node2D

func _init() -> void:
	PlayScene.instance.conductor.step_hit.connect(step_hit)
	PlayScene.instance.conductor.beat_hit.connect(beat_hit)

func init_characters():
	$dj_pos.visible = false
	$player_pos.visible = false
	$opponent_pos.visible = false
	
	PlayScene.instance.dj.position += $dj_pos.global_position
	PlayScene.instance.player.position += $player_pos.global_position
	PlayScene.instance.opponent.position += $opponent_pos.global_position

# some callbacks
func step_hit(beat):pass
func beat_hit(beat):pass
func event_called(event, data):pass
