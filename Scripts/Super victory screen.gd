extends Control

func _process(delta):
	$Label.text = "You won level: \n level_" + str(int(Globals.level) - 1) + "!"
	$coins.text = ":" + str(Globals.coins)
	$score.text = "Score:" + str(Globals.score)


func _on_back_pressed():
	DataState.remove_state_file()
	Data.remove_file()
	DataState.node_data.clear()
	Data.data.clear()
	get_tree().quit()
