extends Control

func _process(delta):
	$Label.text = "You won level" + str(Globals.level) + "!"
	$coins.text = ":" + str(Globals.coins)
	$score.text = ":" + str(Globals.score)


func _on_next_pressed():
	LoadScene.load_scene(self, Globals.level)


func _on_back_pressed():
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
