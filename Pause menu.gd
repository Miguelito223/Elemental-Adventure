extends Control



func _on_return_pressed():
	hide()
	get_tree().paused = false


func _on_back_pressed():
	get_tree().paused = false
	PlayerData.load_file()
	Global.load_scene(self, "res://main_menu.tscn")
