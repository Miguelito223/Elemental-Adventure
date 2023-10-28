extends Node

signal finish_loading

const GAME_SCENE ={
	"level_1": "res://Scenes/level_1.tscn", 
	"level_2": "res://Scenes/level_2.tscn",
	"level_3": "res://Scenes/level_3.tscn",
	"level_4": "res://Scenes/level_4.tscn",
	"level_5": "res://Scenes/level_5.tscn",
	"level_6": "res://Scenes/level_6.tscn", 
	"level_7": "res://Scenes/level_7.tscn",
	"level_8": "res://Scenes/level_8.tscn",
	"level_9": "res://Scenes/level_9.tscn",
	"level_10": "res://Scenes/level_10.tscn"
}

var loading_screen = preload("res://Scenes/loading_screen.tscn")
func load_scene(current_scene, next_scene):
	var loading_screen_intance = loading_screen.instantiate()
	get_tree().get_root().add_child(loading_screen_intance)
	
	var load_path
	if GAME_SCENE.has(next_scene):
		load_path = GAME_SCENE[next_scene]
	else:
		load_path = next_scene
	
	var loader_next_scene
	if ResourceLoader.exists(load_path):
		loader_next_scene = ResourceLoader.load_threaded_request(load_path)
	else:
		print("file no exist")
		return 
	
	await loading_screen_intance.safe_to_load
	if current_scene != null:
		current_scene.queue_free()
	
	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(load_path, load_progress)
		match load_status:
			0:
				print("failed: canot find the resource")
				return
			1:
				if current_scene != null:
					current_scene.queue_free()
				loading_screen_intance.get_node("Control/ProgressBar").value = floor(load_progress[0] * 100.0)
			2:
				print("failed to load")
				return
			3:
				if current_scene != null:
					current_scene.queue_free()
				var new_scene = ResourceLoader.load_threaded_get(load_path).instantiate()
				get_tree().get_root().add_child(new_scene)
				loading_screen_intance.fade_out_loading_screen()
				finish_loading.emit()
				return
