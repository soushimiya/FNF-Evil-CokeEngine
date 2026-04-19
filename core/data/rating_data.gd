extends Node
class_name RatingData

const judgements:Dictionary = {
	"killer": {"score_mult": 1.2, "accuaracy_mult": 1}, # epic has score bonus but not affect to accuracy
	"sick": {"score_mult": 1, "accuaracy_mult": 1},
	"good": {"score_mult": 0.8, "accuaracy_mult": 0.95},
	"bad": {"score_mult": 0.5, "accuaracy_mult": 0.75},
	"shit": {"score_mult": 0.2, "accuaracy_mult": 0.6}
}

static func get_rating_name(diff:float):
	if diff < 20:
		return "killer"
	if diff < 75:
		return "sick"
	elif diff < 100:
		return "good"
	elif diff < 170:
		return "bad"
	return "shit"
