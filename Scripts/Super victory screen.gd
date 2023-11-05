extends Control


func _on_back_pressed():
	DataState.remove_state_file()
	Data.remove_file()
	DataState.node_data_load.clear()
	DataState.node_data_save.clear()
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")
