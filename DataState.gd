extends Node

signal finish_remove_data
signal finish_add_data
signal finish_load_data

var data_state_path = "user://Data_State.json"

func save_file_state():
	print("Creating data load file")
	var datafile = FileAccess.open(data_state_path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persistent")
	for node in save_nodes:
		
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		var node_data = node.save()
		datafile.store_line(JSON.stringify(node_data))

func load_file_state():
	print("loading data state...")
	var datafile = FileAccess.open(data_state_path, FileAccess.READ)
	if FileAccess.file_exists(data_state_path):
		print("data state file found")
		var save_nodes = get_tree().get_nodes_in_group("persistent")
		
		for i in save_nodes:
			i.queue_free()
			
		while datafile.get_position() < datafile.get_length():
			var json = JSON.new()

			var parse_result = json.parse(datafile.get_line())

			var node_data = json.get_data()
			
			if node_data.filename == "res://player.tscn":
				Globals.level = node_data.level
				Globals.hearth = node_data.hearth
				Globals.coins = node_data.coins
				Globals.pos_y = node_data.pos_y
				Globals.pos_x = node_data.pos_x

			var new_object = load(node_data["filename"]).instantiate()
			if get_node(node_data.parent) != null:
				get_node(node_data.parent).add_child(new_object)
			else:
				node_data.parent = "/root/" + Globals.level
				if get_node(node_data.parent) != null:
					get_node(node_data.parent).add_child(new_object)
				else:
					node_data.parent = "/root/level_" + str(int(Globals.level) - 1)
					get_node(node_data.parent).add_child(new_object)
			
			new_object.load(node_data)
				
				
				
func load_file_state_global_vars():
	print("loading data state...")
	var datafile = FileAccess.open(data_state_path, FileAccess.READ)
	if FileAccess.file_exists(data_state_path):
		print("data state file found")
		var save_nodes = get_tree().get_nodes_in_group("persistent")
		
		for i in save_nodes:
			i.queue_free()
			
		while datafile.get_position() < datafile.get_length():
			var json = JSON.new()

			var parse_result = json.parse(datafile.get_line())
			var node_data = json.get_data()
			
			if node_data.filename == "res://player.tscn":
				Globals.level = node_data.level
				Globals.hearth = node_data.hearth
				Globals.coins = node_data.coins
				Globals.pos_y = node_data.pos_y
				Globals.pos_x = node_data.pos_x
		
		print("finish")
	else:
		print("Node data file doesn't exist!")
		save_file_state()
		
func remove_state_file():
	if FileAccess.file_exists(data_state_path):
		DirAccess.remove_absolute(data_state_path)
	finish_remove_data.emit()
	
func _physics_process(delta):
	if Globals.autosave:
		autosave_logic()
	
func autosave_logic():
	var time_passed = Time.get_unix_time_from_system() - Globals.autosaver_start_time
		
	if time_passed > (int(Globals.autosave_length) * 60):
		DataState.save_file_state()
		Globals.autosaver_start_time = Time.get_unix_time_from_system()
