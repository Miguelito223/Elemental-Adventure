extends Node

const GAME_SCENE ={
	"level_1": "res://level_1.tscn", 
	"level_2": "res://level_2.tscn",
	"level_3": "res://level_3.tscn",
	"level_4": "res://level_4.tscn",
	"level_5": "res://level_5.tscn"
}

var loading_screen = preload("res://loading_screen.tscn")

func load_scene(current_scene, next_scene):
	var loading_screen_intance = loading_screen.instantiate()
	get_tree().get_root().call_deferred("add_child", loading_screen_intance)
	
	var load_path
	if GAME_SCENE.has(next_scene):
		load_path = GAME_SCENE[next_scene]
	else:
		load_path = next_scene
	
	var loader_next_scene
	if ResourceLoader.exists(load_path):
		loader_next_scene = ResourceLoader.load_threaded_request(load_path)
		set_process(true)
	else:
		print("file no exist")
		return 
	
	
	await loading_screen_intance.safe_to_load
	current_scene.queue_free()
	
	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(load_path, load_progress)
		match load_status:
			0:
				print("failed: canot find the resource")
				set_process(false)
				return
			1:
				current_scene.queue_free()
				loading_screen_intance.get_node("Control/ProgressBar").value = load_progress[0] * 100.0
			2:
				print("failed to load")
				set_process(false)
				return
			3:
				current_scene.queue_free()
				var new_scene = ResourceLoader.load_threaded_get(load_path).instantiate()
				get_tree().get_root().call_deferred("add_child", new_scene)
				
				loading_screen_intance.fade_out_loading_screen()
				
