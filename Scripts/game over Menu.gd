extends Control

var player 

func _ready():
	if not Network.is_networking:
		get_tree().paused = true
	else:
		player = get_parent().get_node(Globals.map).get_node(str(get_tree().get_multiplayer().get_unique_id()))

func _on_return_pressed():
	if Network.is_networking:
		if player.is_multiplayer_authority():
			UnloadScene.unload_scene(self)
	else:
		get_tree().paused = false
		LoadScene.load_scene(self, Globals.level)
		

func _on_back_pressed():
	if Network.is_networking:
		if player.is_multiplayer_authority():
			get_tree().get_multiplayer().server_disconnected.emit()
			
	else:
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")


