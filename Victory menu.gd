extends Control




func _on_next_pressed():
	Global.load_scene(self, "res://level_2.tscn")


func _on_back_pressed():
	Global.load_scene(self, "res://main_menu.tscn")
