extends Node2D

var DEBUGGING = true

var num_players: int = Globals.num_players

var use_keyboard: bool = Globals.use_keyboard

var players: Array = []
var input_maps: Array = []


@export var move_speed =  0.5
@export var zoom_speed =  0.05
@export var min_zoom = 2
@export var max_zoom = 4
@export var margin = Vector2(100, 25)


@onready var camera = $Camera
@onready var screen_size = get_viewport_rect().size

var rng = RandomNumberGenerator.new()

const player_scene = preload("res://Scenes/player.tscn")

func _ready():

	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))
		
	DataState.load_file_state()	
	Data.load_file()

	if DataState.node_data.is_empty():
		print("node_data is empy")
		for player_index in range(Globals.num_players):
			add_player(player_index)

		if Globals.num_players == 0:
			Globals.use_keyboard = true
			for player_index in range(1):
				add_player(player_index)
		
		DataState.save_file_state()
		Data.save_file()



	Signals.level_loaded.emit()

func _process(_delta):
	if !players or players.is_empty() or players == null: 
		return
	
	var pos = Vector2.ZERO

	for player in players:
		if not is_instance_valid(player):
			return
		pos += player.position

	pos /= players.size()

	camera.position = lerp(camera.position, pos, move_speed)
	
	var rect = Rect2(camera.position, Vector2.ONE)

	for player in players:
		rect = rect.expand(player.position)

	rect = rect.grow_individual(margin.x, margin.y, margin.x, margin.y)

	var _distance = max(rect.size.x, rect.size.y)

	var zoom_range 

	if rect.size.x > rect.size.y * screen_size.aspect():
		zoom_range = clamp(rect.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		zoom_range = clamp(rect.size.y / screen_size.y, min_zoom, max_zoom)

	camera.zoom = lerp(camera.zoom, Vector2.ONE * zoom_range, zoom_speed)



func remove_player(player_index):
	var player = players[-1]
	players.remove_at(player_index)
	if is_instance_valid(player):
		player.queue_free()
	print(players)

func add_player(player_index):

	print(player_index)

	if player_index < players.size():
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
	player.name = names[player_index]
	Globals.player_name = names[player_index]

	if not DataState.node_data.is_empty():
		if DataState.node_data.filename == "res://Scenes/player.tscn":
			player.load(DataState.node_data)
	else:
		print("node_data is empy")
		Globals.hearths[str(Globals.player_index)] = 3
		DataState.save_file_state()
		Data.save_file()


	if not Globals.hearths.has(str(Globals.player_index)):
		Globals.hearths[str(Globals.player_index)] = 3
		DataState.save_file_state()
		Data.save_file()

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
			DataState.save_file_state()
			Data.save_file()
			DataState.remove_state_file()
			DataState.node_data.clear()
			LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")



func _on_death_zone_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		body.damage(3)
