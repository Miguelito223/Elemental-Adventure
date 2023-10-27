extends Node2D

func _ready():
	Signals.level_loaded.emit()
	DataState.save_file_state()
	DataState.load_file_state()

func _on_area_2d_body_entered(body):
	if body.get_scene_file_path() == "res://player.tscn":
		body.damage(3)


func _on_victory_zone_body_entered(body):
	if body.get_scene_file_path() == "res://player.tscn":
		body.changelevel()
		LoadScene.load_scene(self, Globals.level)
