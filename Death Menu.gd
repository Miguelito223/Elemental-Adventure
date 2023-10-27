extends Control

func _on_return_pressed():
	LoadScene.load_scene(self, Globals.level)

func _on_back_pressed():
	DataState.save_file_state()
	LoadScene.load_scene(self, "res://main_menu.tscn")


