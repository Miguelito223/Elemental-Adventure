extends Control

func _ready():
	get_tree().paused = true

func _on_return_pressed():

	if Network.is_networking:
		if is_multiplayer_authority():
			var player = get_parent().get_node(Globals.map).get_node(str(multiplayer.get_unique_id()))
			Network.connected_ids.clear()
			queue_free()
			get_tree().paused = false
			player.get_node("Camera2D").enabled = true
			

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


