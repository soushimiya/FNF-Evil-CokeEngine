-- make game camera move based off current target player's note
-- also this is example of scripting!1!!
function on_opponent_note_hit(note, is_sustain)
	if not is_sustain and game.camera_target == "opponent" then
		move_cam_by_note(note.note_data)
	end
end

function on_good_note_hit(note, is_sustain)
	if not is_sustain and game.camera_target == "player" then
		move_cam_by_note(note.note_data)
	end
end

function move_cam_by_note(id)
	local ex_campos = Vector2(0, 0)

	if id == 0 then
		ex_campos = Vector2(-10, 0)
	elseif id == 1 then
		ex_campos = Vector2(0, 10)
	elseif id == 2 then
		ex_campos = Vector2(0, -10)
	else
		ex_campos = Vector2(10, 0)
	end

	game:move_camera_extend(ex_campos)
end
