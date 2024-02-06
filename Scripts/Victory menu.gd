extends Control

func _ready():
	pass

func _process(_delta):
	$Label.text = "You Completed Level: \n level " + str(Globals.level_int - 1) + "!!!"
	$VBoxContainer2/energys.text = "Energys Balls:" + str(Globals.energys[0] + Globals.energys[1] + Globals.energys[2] + Globals.energys[3] )
	$VBoxContainer2/score.text = "Score:" + str(Globals.score[0] + Globals.score[1] + Globals.score[2] + Globals.score[3])


func _on_next_pressed():
	LoadScene.load_scene(self, Globals.level)


func _on_back_pressed():
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
