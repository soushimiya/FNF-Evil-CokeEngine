extends Node
class_name CharacterData
# Called when the node enters the scene tree for the first time.

const default_data = {
	"id": "bf",
	"texture": "characters/BOYFRIEND",
	"position": Vector2(),
	"camera_position": Vector2(),
	"animations": [],
	"idle_animations": ["idle"],
	"scale": 1,
	"antialiasing": true,
	"flip_horizon": true,
	
	"icon": "bf",
	"sing_duration": 4
}

static func get_character(char:String):
	var data = default_data.duplicate(true)
	var character_path = "res://game/characters/" + char + "/" + char + ".lua"
	if !ResourceLoader.exists(character_path):
		char = "bf"
		character_path = "res://game/characters/bf/bf.lua"
	
	data.id = char
	var lua_script = LuaModule.new(character_path)
	for key in data.keys():
		if key != "id":
			lua_script.lua.globals[key] = data[key]
	lua_script.do()
	# store data
	for key in data.keys():
		# okay... who made playtime cry...?????
		if key == "animations":
			for entry in lua_script.lua.globals["animations"].to_array():
				var thing = entry.to_dictionary()
				thing.indices = thing.indices.to_array()
				data["animations"].push_back(thing)
		elif key == "idle_animations":
			if typeof(lua_script.lua.globals["idle_animations"]) != TYPE_ARRAY:
				data["idle_animations"] = lua_script.lua.globals["idle_animations"].to_array()
		elif key != "id":
			data[key] = lua_script.lua.globals[key]
	
	return data

static func list_character() -> Array:
	var final_array = []
	if DirAccess.dir_exists_absolute("res://game/characters/"):
		var dirs = DirAccess.get_directories_at("res://game/characters/")
		for d in dirs:
			if FileAccess.file_exists("res://game/characters/" + d + "/" + d + ".lua"):
				final_array.push_back(d)
	return final_array
