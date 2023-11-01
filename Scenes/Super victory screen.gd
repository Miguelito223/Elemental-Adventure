extends Control


func _on_back_pressed():
	DataState.remove_state_file()
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
