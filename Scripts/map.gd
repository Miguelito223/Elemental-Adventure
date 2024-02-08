extends Node2D

var DEBUGGING = true

var connected_ids: Array = []
var players: Array = []
var input_maps: Array = []

var move_speed =  0.5
var zoom_speed =  0.05
var min_zoom = 1.5
var max_zoom = 3
var margin = Vector2(100, 25)

@onready var camera = $Camera
@onready var screen_size = get_viewport_rect().size

var rng = RandomNumberGenerator.new()

var player_scene = preload("res://Scenes/player.tscn")

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))
	
	DataState.load_file_state()

	add_player(0)

	Network.multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_player", new_peer_id)
			rpc_id(new_peer_id, "add_previus_player", connected_ids)
			add_player(new_peer_id)
	)
			

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
		var player = players[-1]
		players.remove_at(player_id)
		if is_instance_valid(player):
			player.queue_free()

@rpc		
func add_newly_player(player_id):
	if Network.is_networking:
		add_player(player_id)
@rpc	
func add_previus_player(player_id):
	if Network.is_networking:
		for player_ids in player_id:
			add_player(player_ids)

func add_player(player_id):
	if Network.is_networking:
		Network.multiplayer_players_numbers += 1

		if player_id < players.size():
			return

		players.append(player_scene.instantiate())
		connected_ids.append(player_id)

		var player = players[-1]

		player.setposspawn()

		player.device_num = player_id

		player.name = Globals.player_name[player_id]
		player.ball_color = Globals.ball_color_dict[player_id]
		player.player_color = Globals.player_color_dict[player_id]

		player.player_name = Globals.player_name[player_id]
		player.energys = Globals.energys[player_id]
		player.score = Globals.score[player_id]
		player.Hearths = Globals.hearths[player_id]
		player.deaths = Globals.deaths[player_id]

		if DataState.node_data.is_empty():
			print("node data is empy")
			player.setposspawn()
		else: 
			print("node data is not empy")
			for i in DataState.node_data:
				var node_data = DataState.node_data[i]
				if node_data.filename == "res://Scenes/player.tscn":
					if node_data.device_num == player_id or node_data.player_name == player.player_name:
						print(node_data)
						player.load_state(node_data)


		input_maps.append({
			"right{n}".format({"n":player_id}): Vector2.RIGHT,
			"left{n}".format({"n":player_id}): Vector2.LEFT,
			"jump{n}".format({"n":player_id}): null,
			"shoot{n}".format({"n":player_id}): null,
			"pause{n}".format({"n":player_id}): null,
			"down{n}".format({"n":player_id}): null,
		})
		
		player.ui_inputs = input_maps[player_id]

		Globals._inputs_player(player_id)

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


