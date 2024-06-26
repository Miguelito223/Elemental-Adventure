extends CanvasLayer

var before_level 
var player

func _ready():
	get_tree().paused = true

	if Network.is_networking:
		before_level = get_parent().get_node("level_" + str(Globals.level_int))
		player = before_level.get_node(str(multiplayer.get_unique_id()))

		
func _on_return_pressed():
	if Network.is_networking:
		if player.is_multiplayer_authority():
			get_tree().paused = false
			UnloadScene.unload_scene(self)
	else:
		get_tree().paused = false
		LoadScene.load_scene(self, Globals.level)
		

func _on_back_pressed():
	if Network.is_networking:
		if player.is_multiplayer_authority():
			multiplayer.multiplayer_peer.close() 
	else:
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
