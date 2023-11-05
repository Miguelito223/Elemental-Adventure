extends Control

func _process(delta):
	$Label.text = "You won level: \n level_" + str(int(Globals.level) - 1) + "!"
	$coins.text = ":" + str(Globals.coins)
	$score.text = "Score:" + str(Globals.score)


func _on_next_pressed():
	LoadScene.load_scene(self, Globals.level)


func _on_back_pressed():
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
