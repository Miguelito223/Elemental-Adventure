extends Control




func _on_next_pressed():
	LoadScene.load_scene(self, Globals.level)


func _on_back_pressed():
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
