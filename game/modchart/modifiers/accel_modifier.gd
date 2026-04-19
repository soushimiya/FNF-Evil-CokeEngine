extends ModchartModifier
class_name AccelModifier

func _init() -> void:
	self.submods = {
		"brake": ModchartSubModifier.new(),
		"wave": ModchartSubModifier.new()
	}

func note_process(note:Note, player:int):
	if !note.auto_follow:
		return
		
	var note_diff = PlayScene.instance.conductor.song_position - note.strum_time

	var boost = percent[player]
	var brake = submods["brake"].percent[player]
	var wave = submods["wave"].percent[player]
	
	var effect_height = 500
	var y_adjust:float = 0
		
	if(brake != 0):
		var scale = ModchartManager.scale(note_diff, 0, effect_height, 0, 1)
		var off = note_diff * scale
		y_adjust += clampf(brake * (off - note_diff),-400,400)

	if(boost!=0):
		var off = note_diff * 1.5 / ((note_diff + effect_height/1.2)/effect_height)
		y_adjust += clampf(boost * (off - note_diff),-400,400)

	y_adjust += wave * 20 * sin(note_diff/38)
	note.position.y += y_adjust
