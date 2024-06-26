extends CanvasLayer

var before_level

func _ready():
	get_tree().paused = true
	
	if Network.is_networking:
		before_level = get_parent().get_node("level_" + str(Globals.level_int - 1))
		
	

func _process(_delta):
	if Network.is_networking:
		$Label.text = "You Completed Level: \n level " + str(Globals.level_int - 1) + "!!!"
		$VBoxContainer2/energys.text = "Energys Balls:" + str(Network.energys[0] + Network.energys[1] + Network.energys[2] + Network.energys[3] )
		$VBoxContainer2/score.text = "Score:" + str(Network.score[0] + Network.score[1] + Network.score[2] + Network.score[3])
	else:
		$Label.text = "You Completed Level: \n level " + str(Globals.level_int - 1) + "!!!"
		$VBoxContainer2/energys.text = "Energys Balls:" + str(Globals.energys[0] + Globals.energys[1] + Globals.energys[2] + Globals.energys[3] )
		$VBoxContainer2/score.text = "Score:" + str(Globals.score[0] + Globals.score[1] + Globals.score[2] + Globals.score[3])

@rpc("any_peer", "call_local")
func unload_actual_scene():
	UnloadScene.unload_scene(self)

func _on_next_pressed():
	if Network.is_networking:
		if multiplayer.is_server():
			get_tree().paused = false
			unload_actual_scene.rpc()
			LoadScene.load_scene(null, Globals.level)
	else:
		get_tree().paused = false
		LoadScene.load_scene(self, Globals.level)


func _on_back_pressed():
	if Network.is_networking:
		multiplayer.multiplayer_peer.close()
	else:
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
