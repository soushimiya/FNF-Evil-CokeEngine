extends Node2D
# TODO: make this custom object

var parent_note#:Note
var length:float = 0
const sustain_height:float = 87

var last_length_old = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if parent_note != null:
		var speed_adjust = (parent_note.strumline.scroll_speed*0.45) # Scroll Speed shit...
		# destroying sustain lol shitty implement
		if !parent_note.auto_follow:
			speed_adjust = 1
			var last_length = ((parent_note.strum_time + parent_note.sustain_length) - Main.scene.conductor.song_position) * (parent_note.strumline.scroll_speed*0.45)
			var sus_length_adjust = (last_length / Main.scene.conductor.step_crotchet)
			self.length = sus_length_adjust
			if last_length_old != sus_length_adjust:
				last_length_old = sus_length_adjust
				parent_note.strumline.note_hit.emit(parent_note, true)
			# destroying shit
			if sus_length_adjust <= 0:
				self.queue_free()

		self.global_position = parent_note.global_position
		$sustain.scale.y = length * speed_adjust
	$tail.position.y = sustain_height * $sustain.scale.y
	
	if parent_note.scale.y < 0:
		$sustain.flip_h = true
		$tail.flip_h = true
		scale.y = -1
	else:
		$sustain.flip_h = false
		$tail.flip_h = false
		scale.y = 1

func update_anim():
	match parent_note.note_data:
		0:
			$sustain.frame = 0
			$tail.frame = 1
		1:
			$sustain.frame = 2
			$tail.frame = 3
		2:
			$sustain.frame = 4
			$tail.frame = 5
		3:
			$sustain.frame = 6
			$tail.frame = 7
