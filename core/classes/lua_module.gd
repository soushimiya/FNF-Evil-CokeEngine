extends Node
class_name LuaModule

var lua:LuaState = null
var script_path = ""

func _init(path:String) -> void:
	script_path = path
	if FileAccess.file_exists(script_path):
		_initLua()
	else:
		print("Failed to Load Script File from: " + script_path)

# Initalize LuaState and adding Variables and uhh idk!
func _initLua():
	lua = LuaState.new()
	lua.open_libraries()

	lua.globals["print"] = func(t): print(t)
	lua.globals["make_callable"] = func(f):
		if (lua.globals.to_dictionary().has(f)):
			return lua.globals[f].to_callable()

	lua.globals["PlayScene"] = PlayScene
	lua.globals["FNFSprite2D"] = FNFSprite2D

var runtime_dictionary:Dictionary
func do():
	var result = lua.do_file(script_path)
	if result is LuaError:
		printerr("Error in Lua code: ", result)
	runtime_dictionary = lua.globals.to_dictionary()

var runtime_callables:Dictionary = {}
func call_lua(function:String, args:Array = []):
	if runtime_dictionary != null && runtime_dictionary.has(function):
		if !runtime_callables.has(function):
			runtime_callables[function] = runtime_dictionary[function].to_callable()
		return runtime_callables[function].callv(args)
