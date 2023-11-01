extends Node



var data_state_path = "user://Data_State.json"
var node_data = {}

func save_file_state():
	print("Creating state data file")
	var datafile = FileAccess.open(data_state_path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persistent")
	for node in save_nodes:
		
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		node_data = node.save()
		datafile.store_line(JSON.stringify(node_data))
	
	Signals.finish_add_data.emit()
	print("finish")

func load_file_state():
	print("loading state data...")
	
	var datafile = FileAccess.open(data_state_path, FileAccess.READ)
	
	if not FileAccess.file_exists(data_state_path):
		print("State data file doesn't exist!")
		save_file_state()
		return null

	if datafile.get_length() <= 0:
		print("State data file empty!")
		save_file_state()
		return null
	
	print("data state file found")
	
	var save_nodes = get_tree().get_nodes_in_group("persistent")
	
	for i in save_nodes:
		i.queue_free()

	
	var json_string
	
	var json

	var parse_result

	while datafile.get_position() < datafile.get_length():
		json_string = datafile.get_line()
		
		json = JSON.new()
		
		parse_result = json.parse(json_string)
		
		node_data = json.get_data()

		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var new_object = load(node_data.filename).instantiate()

		if node_data.filename == "res://Scenes/player.tscn":
			print("loading player, name: %s..." % node_data.name)
			var level = get_tree().get_root().get_node(Globals.level)
			
			if Globals.num_players == 0:
				Globals.use_keyboard = true
				for player_index in range(1):
					level.add_player(player_index)
			else:
				Globals.use_keyboard = false
				for player_index in range(Globals.num_players):
					level.add_player(player_index)
			
			
			print("loading finish...")
		else:
			print("creating node '%s'" % new_object.name)
			if get_node(node_data.parent) != null:
				get_node(node_data.parent).add_child(new_object)
			else:
				print("fixing the parent...")
				node_data.parent = "/root/" + Globals.level
				
				if get_node(node_data.parent) != null:
					get_node(node_data.parent).add_child(new_object)
				else:
					print("fixing the parent again...")
					node_data.parent = "/root/level_" + str(int(Globals.level) - 1)
					if get_node(node_data.parent) != null:
						get_node(node_data.parent).add_child(new_object)
					else:
						print("null parent of object '%s'" % new_object.name)
						return
			print("creating node '%s'" % new_object.name)
			new_object.load(node_data)
	
	print("finish")
	Signals.finish_load_data.emit()
	return node_data


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		DataState.save_file_state()
		
func remove_state_file():
	if FileAccess.file_exists(data_state_path):
		DirAccess.remove_absolute(data_state_path)
	Signals.finish_remove_data.emit()
	
	
func autosave_logic():
	var time_passed = Time.get_unix_time_from_system() - int(Globals.autosaver_start_time)
		
	if (time_passed > (int(Globals.autosave_length) * 60)) :
		save_file_state()
		Data.save_file()
		Globals.autosaver_start_time = str(Time.get_unix_time_from_system())
