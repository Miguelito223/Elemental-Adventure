extends Control

func _on_return_pressed():
	if Network.is_networking:
		LoadScene.load_scene(self, Globals.map)
	else:
		LoadScene.load_scene(self, Globals.level)

func _on_back_pressed():
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")


