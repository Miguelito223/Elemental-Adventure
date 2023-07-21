extends Control

func _on_return_pressed():
	PlayerData.load_file()
	Global.load_scene(self, PlayerData.playerdata.level)

func _on_back_pressed():
	PlayerData.load_file()
	Global.load_scene(self, "res://main_menu.tscn")


