extends Control



func _on_return_pressed():
	hide()
	get_tree().paused = false


func _on_back_pressed():
	get_tree().paused = false
	PlayerData.load_file()
	Global.load_scene(get_parent().get_parent().get_parent(), "res://main_menu.tscn")


func _on_button_pressed():
	PlayerData.save_file()
