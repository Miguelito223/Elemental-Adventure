extends Node2D

var DEBUGGING = true

var connected_ids: Array = []
var players: Array = []
var input_maps: Array = []

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

	get_parent().multiplayer.peer_connected.connect(
		func(id):
			await get_tree().create_timer(1).timeout
			add_player(Network.connection_count, id)
	)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)

	for id in multiplayer.get_peers():
		add_player(Network.connection_count, id)

	if not OS.has_feature("dedicated_server"):
		add_player(Network.connection_count, 1)
		
	Signals.level_loaded.emit()


func remove_player(player_id):
	if Network.is_networking:
		var player = get_node(str(player_id))
		if is_instance_valid(player):
			player.queue_free()

func add_player(player_index, player_id):
	if Network.is_networking:

		if player_index < players.size():
			return

		players.append(player_scene.instantiate())

		var player = players[-1]

		connected_ids.append(player_id)

		player.position = Vector2(449, -219)

		player.device_num = player_index

		player.name =  str(player_id)
		player.ball_color = Globals.ball_color_dict[player_index]
		player.player_color = Globals.player_color_dict[player_index]

		player.player_name = str(player_id)
		player.energys = Globals.energys[player_index]
		player.score = Globals.score[player_index]
		player.Hearths = Globals.hearths[player_index]
		player.deaths = Globals.deaths[player_index]
		
		input_maps.append({
			"right{n}".format({"n":player_index}): Vector2.RIGHT,
			"left{n}".format({"n":player_index}): Vector2.LEFT,
			"jump{n}".format({"n":player_index}): null,
			"shoot{n}".format({"n":player_index}): null,
			"pause{n}".format({"n":player_index}): null,
			"down{n}".format({"n":player_index}): null,
		})
		
		player.ui_inputs = input_maps[player_index]

		Globals._inputs_player(player_index)

		add_child(player)

func _exit_tree():
	if not multiplayer.is_server():
		return
	get_parent().multiplayer.peer_connected.disconnect(
		func(id):
			await get_tree().create_timer(1).timeout
			add_player(Network.connection_count, id)
	)
	get_parent().multiplayer.peer_disconnected.disconnect(remove_player)
	

