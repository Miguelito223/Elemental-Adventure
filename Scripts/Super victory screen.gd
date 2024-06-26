extends CanvasLayer

func _ready():
	get_tree().paused = true

func _process(_delta):
	if Network.is_networking:
		$Label.text = "You Completed Level: \n level " + str(Globals.level_int - 1) + "!!!"
		$VBoxContainer2/energys.text = "Energys Balls:" + str(Network.energys[0] + Network.energys[1] + Network.energys[2] + Network.energys[3] )
		$VBoxContainer2/score.text = "Score:" + str(Network.score[0] + Network.score[1] + Network.score[2] + Network.score[3])
	else:
		$Label.text = "You Completed Level: \n level " + str(Globals.level_int - 1) + "!!!"
		$VBoxContainer2/energys.text = "Energys Balls:" + str(Globals.energys[0] + Globals.energys[1] + Globals.energys[2] + Globals.energys[3] )
		$VBoxContainer2/score.text = "Score:" + str(Globals.score[0] + Globals.score[1] + Globals.score[2] + Globals.score[3])

	

func _on_back_pressed():
	if Network.is_networking:
		get_tree().paused = false
		multiplayer.multiplayer_peer.close() 
		DataState.remove_state_file()
		Data.remove_file()
		get_tree().quit()
	else:
		get_tree().paused = false
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
		DataState.remove_state_file()
		Data.remove_file()
		get_tree().quit()