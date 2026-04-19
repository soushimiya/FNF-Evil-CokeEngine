extends Node

static var width:float:
	get():
		return ProjectSettings.get_setting("display/window/size/viewport_width")
static var height:float:
	get():
		return ProjectSettings.get_setting("display/window/size/viewport_height")

const note_safe_zone:float = 160
