extends Control



func _on_return_pressed():
	hide()
	get_tree().paused = false


func _on_back_pressed():
	get_tree().paused = false
	DataState.save_file_state()
	LoadScene.load_scene(get_parent().get_parent().get_parent(), "res://Scenes/main_menu.tscn")


func _on_button_pressed():
	DataState.save_file_state()
