extends Node2D

func _ready():
	DataState.load_file_state()
	Signals.level_loaded.emit()

func _on_area_2d_body_entered(body):
	if body.get_scene_file_path() == "res://player.tscn":
		body.damage(3)

func _physics_process(delta):
	if Globals.autosave:
		DataState.autosave_logic()

func _on_victory_zone_body_entered(body):
	if body.get_scene_file_path() == "res://player.tscn":
		body.changelevel()
		body.setposspawn()
		DataState.remove_state_file()
		LoadScene.load_scene(self, Globals.level)

