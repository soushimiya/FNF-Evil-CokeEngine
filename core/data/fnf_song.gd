extends Resource
class_name FNFSong

const default_chart:Dictionary = {
	"bpm": 100,
	"scroll_speed": 1.0,

	"player": {"character": "bf", "notes":[]},
	"opponent": {"character": "dad", "notes":[]},
	"dj": {"character": "gf", "notes":[]},

	"stage": "Stage"
}

@export var id:String

@export_category("Metadata")
@export var display_name:String:
	get():
		if display_name == null:
			return self.name
		return display_name

@export var artist:String = ""
@export var charter:String = ""

@export var difficulties:Array[String] = ["easy", "normal", "hard"]

@export_category("Audio")
@export var instrumental:AudioStream
@export var player_vocals:AudioStream
@export var opponent_vocals:AudioStream
@export_category("Extra")
@export_multiline var extra_description:String = ""

var charts:Dictionary:
	get():
		if charts.size() <= 0:
			for diff in difficulties:
				var d:Dictionary = default_chart
				var chart_path = "res://game/charts/" + self.id + "/chart/" + diff + ".json"
				if FileAccess.file_exists(chart_path):
					d = JSON.parse_string(FileAccess.get_file_as_string(chart_path))
				charts[diff] = d
		
		return charts

var events:Array:
	get():
		var event_path = "res://game/levels/" + self.id + "/events.json"
		if FileAccess.file_exists(event_path):
			var d = JSON.parse_string(FileAccess.get_file_as_string(event_path))
			return d.events
		return []
