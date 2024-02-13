extends Control

func _ready():
	if not Network.is_networking:
		get_tree().paused = true

func _on_return_pressed():
	if Network.is_networking:
		if is_multiplayer_authority():
			self.queue_free()
	else:
		get_tree().paused = false
		LoadScene.load_scene(self, Globals.level)
		

func _on_back_pressed():
	if Network.is_networking:
		if is_multiplayer_authority():
			get_parent().multiplayer.multiplayer_peer = null
			Network.is_networking = false
			Network.connected_ids.clear()
			LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
	else:
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")


