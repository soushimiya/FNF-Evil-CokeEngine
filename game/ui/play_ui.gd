extends Node2D

var game

 # made these shits static cuz it looks cool on story mode hahahahaha
static var health_lerp:float = 1

static var score_lerp:int = 1

func init_hud():
	$icon_p1.load(game.player.icon)
	$icon_p2.load(game.opponent.icon)
	if SaveData.data.downscroll:
		for obj in [$health_bar, $icon_p1, $icon_p2, $score_text]:
			obj.position.y -= 570

func beat_hit(beat:int):
	if beat % 2 == 0:
		$icon_p1.bop()
		$icon_p2.bop()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_lerp = lerpf(health_lerp, game.health, 0.01)
	$health_bar.value = health_lerp
	
	$icon_p1.health = game.health
	$icon_p2.health = game.health
	
	
	$icon_p1.position.x = $health_bar.position.x/2 + (580 * remap($health_bar.value, 0, 2, 100, 0) * 0.01 + 220)
	$icon_p2.position.x = $health_bar.position.x/2 + (580 * remap($health_bar.value, 0, 2, 100, 0) * 0.01 + 140)
	
	var lerp_size = 0.01
	score_lerp = lerp(score_lerp, int(game.score), lerp_size)
	
	$score_text.text = 'Score: ' + CokeUtil.format_money(score_lerp) + ' // Misses: ' + str(int(game.misses)) + ' // Accuracy: ' + str(int(game.accuracy)) + '%'
	if PlayScene.instance.get_node("hud/player_strums").botplay:
		$score_text.text += ' [color=GRAY](Botplay)[/color]'
