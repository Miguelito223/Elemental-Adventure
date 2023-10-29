extends Node2D

var DEBUGGING = true

signal disconnected
signal connected

var num_players = 0
var use_keyboard = false

var players = []
var input_maps = []

var rng = RandomNumberGenerator.new()

const player_scene = preload("res://Scenes/player.tscn")

func _ready():

	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
			}))

	for player_index in range(num_players):
		add_player(player_index)

	if num_players == 0:
		use_keyboard = true
		# for player_index in range(1):
		for player_index in range(1):
			add_player(player_index)
		
	
	
	Signals.level_loaded.emit()


func add_player(player_index):

	if player_index < players.size():
		emit_signal("connected", players[player_index].player_name)
		return

	players.append(player_scene.instantiate())

	var player = players[-1]

	var colornames: Array = [
		"white",
		"blue",
		"yellow",
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
	player.name = names[player_index]
	player.scale = Vector2(Globals.size_x, Globals.size_y)
	player.position = Vector2(Globals.pos_x, Globals.pos_y)
	

	input_maps.append({
		"ui_right{n}".format({"n":player_index}): Vector2.RIGHT,
		"ui_left{n}".format({"n":player_index}): Vector2.LEFT,
		"ui_jump{n}".format({"n":player_index}): null,
		"ui_shot{n}".format({"n":player_index}): null,
	})
	# DEBUGGING
	
	player.ui_inputs = input_maps[player_index]
		
	if not use_keyboard:
		player.device_num = player_index
		
		var right_action
		var right_action_event

		var left_action
		var left_action_event
		
		var jump_action
		var jump_action_event
		
		var shot_action
		var shot_action_event
	
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
		right_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		right_action_event.axis_value =  -1.0 # <---- right
		InputMap.action_add_event(left_action, left_action_event)
		
		jump_action = "ui_jump{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		jump_action_event = InputEventJoypadButton.new()
		jump_action_event.device = player_index
		jump_action_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event(jump_action, jump_action_event)
		
		shot_action = "ui_shot{n}".format({"n":player_index})
		InputMap.add_action(shot_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		shot_action_event = InputEventJoypadButton.new()
		shot_action_event.device = player_index
		shot_action_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event(shot_action, shot_action_event)
		
		
		
	else:
		var arrows: Dictionary = {
			"key_right": KEY_RIGHT,
			"key_left":  KEY_LEFT,
			"key_jump":  KEY_UP,
			"key_shot":  KEY_DOWN,
			}
		var wasd: Dictionary = {
			"key_right": KEY_D,
			"key_left":  KEY_A,
			"key_jump":  KEY_W,
			"key_shot":  KEY_S,
			}
		var hjkl: Dictionary = {
			"key_right": KEY_L,
			"key_left":  KEY_H,
			"key_jump":  KEY_K,
			"key_shot":  KEY_J,
			}
		var uiop: Dictionary = {
			"key_right": KEY_P,
			"key_left":  KEY_U,
			"key_jump":  KEY_O,
			"key_shot":  KEY_I,
			}
		var keymaps: Dictionary = {
			0: arrows,
			1: wasd,
			2: hjkl,
			3: uiop,
			}

		var right_action
		var right_action_event

		var left_action
		var left_action_event
		
		var jump_action
		var jump_action_event
		
		var shot_action
		var shot_action_event
		

		right_action = "ui_right{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		right_action_event = InputEventKey.new()
		right_action_event.physical_keycode = keymaps[player_index]["key_right"]
		InputMap.action_add_event(right_action, right_action_event)

		left_action = "ui_left{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		left_action_event = InputEventKey.new()
		left_action_event.physical_keycode = keymaps[player_index]["key_left"]
		InputMap.action_add_event(left_action, left_action_event)
		
		jump_action = "ui_jump{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		jump_action_event = InputEventKey.new()
		jump_action_event.physical_keycode = keymaps[player_index]["key_jump"]
		InputMap.action_add_event(jump_action, jump_action_event)
		
		shot_action = "ui_shot{n}".format({"n":player_index})
		InputMap.add_action(shot_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		shot_action_event = InputEventKey.new()
		shot_action_event.physical_keycode = keymaps[player_index]["key_shot"]
		InputMap.action_add_event(shot_action, shot_action_event)
		
	add_child(player)
	
	

func remove_player(player_index):
	emit_signal("disconnected", players[player_index].player_name)
	DataState.save_file_state()

func _physics_process(delta):
	if Globals.autosave:
		DataState.autosave_logic()

func _on_victory_zone_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		body.changelevel()
		body.setposspawn()
		DataState.remove_state_file()
		LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")

