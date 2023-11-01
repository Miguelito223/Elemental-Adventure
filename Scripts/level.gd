extends Node2D

var DEBUGGING = true

var num_players: int = 0

var use_keyboard: bool = false

var load_data

var players: Array = []
var input_maps: Array = []

var rng = RandomNumberGenerator.new()

const player_scene = preload("res://Scenes/player.tscn")

func _ready():

	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))
		
		load_data = DataState.load_file_state()

		if load_data == null:

			if Globals.num_players == 0:
				Globals.use_keyboard = true
				for player_index in range(1):
					add_player(player_index)
			else:
				Globals.use_keyboard = false
				for player_index in range(Globals.num_players):
					add_player(player_index)
			
		else:
			load_data
			
	Signals.level_loaded.emit()

func _process(delta):
	if Globals.num_players == 0:
		Globals.use_keyboard = true
	else:
		Globals.use_keyboard = false

func remove_player(player_index):
	Signals.disconnected.emit(player_index)

func add_player(player_index):

	print(player_index)

	if player_index < players.size():
		Signals.connected.emit(player_index)
		return

	players.append(player_scene.instantiate())
	
	var player = players[-1]
	
	if DEBUGGING: # TESTING
		# Random positions are annoying while testing.
		# Hardcode positions for player_index 0 and 1
		if player_index == 0:
			player.start_position = Vector2(-460,-45)
		elif player_index == 1:
			player.start_position = Vector2(-399,-45)
		elif player_index == 2:
			player.start_position = Vector2(-340,-45)
		elif player_index == 3:
			player.start_position = Vector2(-280,-45)
		else:
			player.start_position = Vector2(-460,-45)

	else:
		player.start_position = Vector2(-460,-45)
	
	print(players[-1])

	var colornames: Array = [
		"white",
		"blue",
		"gray",
		"green",
	]
	var names: Array = [
		"Fire",
		"Water",
		"Air",
		"Earth",
	]
	
	var alpha = 1.0 # build
	
	var color_dict: Dictionary = {
		0: Color(colornames[0], alpha), # color, alpha
		1: Color(colornames[1], alpha), # color, alpha
		2: Color(colornames[2], alpha), # color, alpha
		3: Color(colornames[3], alpha), # color, alpha
	}

	player.color = color_dict[player_index]
	player.player_name = names[player_index]
	if DataState.node_data.filename == "res://Scenes/player.tscn":
		player.load(DataState.node_data)


	input_maps.append({
		"ui_right{n}".format({"n":player_index}): Vector2.RIGHT,
		"ui_left{n}".format({"n":player_index}): Vector2.LEFT,
		"ui_jump{n}".format({"n":player_index}): null,
		"ui_shoot{n}".format({"n":player_index}): null,
		"ui_pause{n}".format({"n":player_index}): null,
	})
	print(input_maps[player_index])
	# DEBUGGING
	
	player.ui_inputs = input_maps[player_index]
	
	print(use_keyboard)
		
	if Globals.use_keyboard == false:
		player.device_num = player_index
		
		var right_action: String
		var right_action_event: InputEventJoypadMotion

		var left_action: String
		var left_action_event: InputEventJoypadMotion
		
		var jump_action: String
		var jump_action_event: InputEventJoypadButton
		
		var shot_action: String
		var shot_action_event: InputEventJoypadButton
		
		var pause_action: String
		var pause_action_event: InputEventJoypadButton
	
		right_action = "ui_right{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventJoypadMotion.new()
		right_action_event.device = player_index
		right_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		right_action_event.axis_value =  1.0 # <---- right
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "ui_left{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventJoypadMotion.new()
		left_action_event.device = player_index
		left_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		left_action_event.axis_value =  -1.0 # <---- right
		InputMap.action_add_event(left_action, left_action_event)
		
		jump_action = "ui_jump{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		jump_action_event = InputEventJoypadButton.new()
		jump_action_event.device = player_index
		jump_action_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event(jump_action, jump_action_event)
		
		shot_action = "ui_shoot{n}".format({"n":player_index})
		InputMap.add_action(shot_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		shot_action_event = InputEventJoypadButton.new()
		shot_action_event.device = player_index
		shot_action_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event(shot_action, shot_action_event)
		
		pause_action = "ui_pause{n}".format({"n":player_index})
		InputMap.add_action(pause_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		pause_action_event = InputEventJoypadButton.new()
		pause_action_event.device = player_index
		pause_action_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event(pause_action, pause_action_event)
		
		
	else:
		var arrows: Dictionary = {
			"key_right": KEY_RIGHT,
			"key_left":  KEY_LEFT,
			"key_jump":  KEY_UP,
			"key_shoot":  KEY_DOWN,
			"key_pause": KEY_ESCAPE,
			}
		var wasd: Dictionary = {
			"key_right": KEY_D,
			"key_left":  KEY_A,
			"key_jump":  KEY_W,
			"key_shoot":  KEY_S,
			"key_pause": KEY_ESCAPE,
			}
		var hjkl: Dictionary = {
			"key_right": KEY_L,
			"key_left":  KEY_H,
			"key_jump":  KEY_K,
			"key_shoot":  KEY_J,
			"key_pause": KEY_ESCAPE,
			}
		var uiop: Dictionary = {
			"key_right": KEY_P,
			"key_left":  KEY_U,
			"key_jump":  KEY_O,
			"key_shoot":  KEY_I,
			"key_pause": KEY_ESCAPE,
			}
		var keymaps: Dictionary = {
			0: arrows,
			1: wasd,
			2: hjkl,
			3: uiop,
			}

		var right_action: String
		var right_action_event: InputEventKey

		var left_action: String
		var left_action_event: InputEventKey
		
		var jump_action: String
		var jump_action_event: InputEventKey
		
		var shot_action: String
		var shot_action_event: InputEventKey

		var pause_action: String
		var pause_action_event: InputEventKey
		

		right_action = "ui_right{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventKey.new()
		right_action_event.keycode = keymaps[player_index]["key_right"]
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "ui_left{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventKey.new()
		left_action_event.keycode = keymaps[player_index]["key_left"]
		InputMap.action_add_event(left_action, left_action_event)
		
		jump_action = "ui_jump{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		jump_action_event = InputEventKey.new()
		jump_action_event.keycode = keymaps[player_index]["key_jump"]
		InputMap.action_add_event(jump_action, jump_action_event)
		
		shot_action = "ui_shoot{n}".format({"n":player_index})
		InputMap.add_action(shot_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		shot_action_event = InputEventKey.new()
		shot_action_event.keycode = keymaps[player_index]["key_shoot"]
		InputMap.action_add_event(shot_action, shot_action_event)

		pause_action = "ui_pause{n}".format({"n":player_index})
		InputMap.add_action(pause_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		pause_action_event = InputEventKey.new()
		pause_action_event.keycode = keymaps[player_index]["key_pause"]
		InputMap.action_add_event(pause_action, pause_action_event)
	
	add_child(player)

func _physics_process(_delta):
	if Globals.autosave:
		DataState.autosave_logic()

func _on_victory_zone_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		if Globals.level == "level_10":
			LoadScene.load_scene(self, "res://Scenes/Super victory screen.tscn")
		else:
			body.changelevel()
			body.setposspawn()
			body.position = body.start_position
			DataState.remove_state_file()
			LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")

