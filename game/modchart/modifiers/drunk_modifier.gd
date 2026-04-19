extends ModchartModifier
class_name DrunkModifier

func _init() -> void:
	self.submods = {
		"tipsy": ModchartSubModifier.new(),
		"drunk_speed": ModchartSubModifier.new(),
		"tipsy_speed": ModchartSubModifier.new()
	}
	
func strum_process(strumline, strum_id:float, player:int):
	var drunk_perc = percent[player]
	var tipsy_perc = submods["tipsy"].percent[player]
	var tipsy_speed = ModchartManager.scale(submods["tipsy_speed"].percent[player], 0,1,1,2)
	var drunk_speed = ModchartManager.scale(submods["drunk_speed"].percent[player], 0,1,1,2)

	var time = PlayScene.instance.conductor.song_position/1000
	if(drunk_perc != 0):
		strumline.strums[strum_id].position.x += drunk_perc * (cos((time + strum_id*0.2)*drunk_speed) * 112*0.5)


func note_process(note:Note, player:int):
	if !note.auto_follow:
		return
	var drunk_perc = percent[player]
	var tipsy_perc = submods["tipsy"].percent[player]
	var drunk_speed = ModchartManager.scale(submods["drunk_speed"].percent[player], 0,1,1,2)
	
	var time = PlayScene.instance.conductor.song_position/1000
	
	note.position.x += (drunk_perc*(cos((time + note.note_data*.2 + note.position.y*10/Constant.height)*drunk_speed) * 112*0.5))
