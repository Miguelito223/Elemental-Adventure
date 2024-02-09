extends Node2D

var DEBUGGING = true

var connected_ids: Array = []
var players: Array  =  []
var input_maps: Array = []

var move_speed =  0.5
var zoom_speed =  0.05
var min_zoom = 1.5
var max_zoom = 3
var margin = Vector2(100, 25)

@onready var camera = $Camera
@onready var screen_size = get_viewport_rect().size

var rng = RandomNumberGenerator.new()

@export var player_scene = preload("res://Scenes/player.tscn")

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))
		
	if not multiplayer.is_server():
		return

	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)

	for id in multiplayer.get_peers():
		add_player(id)

	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
	Signals.level_loaded.emit()
	

func _process(_delta):
	camera_settings()

func camera_settings():
	if !players or players.is_empty() or players == null: 
		return

	if margin == null or not margin: 
		move_speed =  0.5
		zoom_speed =  0.05
		min_zoom = 2
		max_zoom = 4
		margin = Vector2(100, 25)
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


func remove_player(player_id):
	if Network.is_networking:
		var player = get_node(str(player_id))
		if is_instance_valid(player):
			player.queue_free()

func add_player(player_id):
	if Network.is_networking:

		Network.connection_count += 1

		if Network.connection_count < players.size():
			return

		players.append(player_scene.instantiate())

		var player = players[-1]

		connected_ids.append(player_id)

		player.setposspawn()

		player.device_num = Network.connection_count - 1

		player.name =  str(player_id)
		player.ball_color = Globals.ball_color_dict[Network.connection_count - 1]
		player.player_color = Globals.player_color_dict[Network.connection_count - 1]

		player.player_name = str(player_id)
		player.energys = Globals.energys[Network.connection_count - 1]
		player.score = Globals.score[Network.connection_count - 1]
		player.Hearths = Globals.hearths[Network.connection_count - 1]
		player.deaths = Globals.deaths[Network.connection_count - 1]


		input_maps.append({
			"right{n}".format({"n":Network.connection_count - 1}): Vector2.RIGHT,
			"left{n}".format({"n":Network.connection_count - 1}): Vector2.LEFT,
			"jump{n}".format({"n":Network.connection_count - 1}): null,
			"shoot{n}".format({"n":Network.connection_count - 1}): null,
			"pause{n}".format({"n":Network.connection_count - 1}): null,
			"down{n}".format({"n":Network.connection_count - 1}): null,
		})
		
		player.ui_inputs = input_maps[Network.connection_count - 1]

		Globals._inputs_player(Network.connection_count - 1)

		add_child(player)


func _physics_process(_delta):
	if Globals.autosave:
		DataState.autosave_logic()

func _on_victory_zone_body_entered(body):
	if body.is_in_group("player"):
		if body.device_num == 0:
			if Globals.level_int == 31:
				body.changelevel()
				body.last_position = null
				body.setposspawn()
				DataState.remove_state_file()
				LoadScene.load_scene(self, "res://Scenes/Super victory screen.tscn")
			else:
				body.changelevel()
				body.last_position = null
				body.setposspawn()
				DataState.remove_state_file()
				LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")
		else:
			remove_player(body.device_num)


