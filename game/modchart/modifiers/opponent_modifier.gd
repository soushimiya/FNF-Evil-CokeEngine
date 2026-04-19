extends ModchartModifier
class_name OpponentModifier

func strum_process(strumline, strum_id:float, player:int):
	if (percent[player] == 0):
		return

	var dist_x = Constant.width / 2
	strumline.strums[strum_id].position.x += dist_x * sign((player + 1) * 2 - 3) * percent[player]
	
func note_process(note:Note, player:int):
	if (percent[player] == 0):
		return

	var dist_x = Constant.width / 2
	note.position.x += dist_x * sign((player + 1) * 2 - 3) * percent[player]
