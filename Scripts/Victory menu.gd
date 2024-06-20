extends Control

var before_level

func _ready():
	if Network.is_networking:
		before_level = get_parent().get_node("level_" + str(Globals.level_int - 1))
	else:
		get_tree().paused = true
	

func _process(_delta):
	$CanvasLayer/Label.text = "You Completed Level: \n level " + str(Globals.level_int - 1) + "!!!"
	$CanvasLayer/VBoxContainer2/energys.text = "Energys Balls:" + str(Globals.energys[0] + Globals.energys[1] + Globals.energys[2] + Globals.energys[3] )
	$CanvasLayer/VBoxContainer2/score.text = "Score:" + str(Globals.score[0] + Globals.score[1] + Globals.score[2] + Globals.score[3])

func _on_next_pressed():
	if Network.is_networking:
		if multiplayer.is_server():
			LoadScene.load_scene(self, Globals.level)
	else:
		get_tree().paused = false
		LoadScene.load_scene(self, Globals.level)


func _on_back_pressed():
	if Network.is_networking:
		multiplayer.multiplayer_peer.close()
	else:
		LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
