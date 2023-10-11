extends Control

func _on_return_pressed():
	Data.load_file()
	Global.load_scene(self, Data.data.player_data.level)

func _on_back_pressed():
	Data.load_file()
	Global.load_scene(self, "res://main_menu.tscn")


