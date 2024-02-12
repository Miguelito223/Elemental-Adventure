extends Control

func _on_return_pressed():
	if Network.is_networking:
		if is_multiplayer_authority():
			LoadScene.load_scene(self, Globals.map)
	else:
		LoadScene.load_scene(self, Globals.level)

func _on_back_pressed():
	if Network.is_networking:
		if is_multiplayer_authority():
			get_parent().multiplayer.multiplayer_peer = null
			Network.is_networking = false
			LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
	else:
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")


