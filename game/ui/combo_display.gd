extends Node2D

var number:int = 0:
	set(value):
		for node in get_children():
			remove_child(node)
			node.queue_free()
		number = value
		var str_num = str(value)
		for i in str_num.length():
			var spr = Sprite2D.new()
			spr.texture = load("res://game/play_ui/assets/combo/" + str_num.substr(i, 1) + ".png")
			self.add_child(spr)
			spr.position.x = 100*i
