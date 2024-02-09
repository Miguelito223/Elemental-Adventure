extends Node2D

var DEBUGGING = true

var connected_ids: Array = []
var players: Array  =  []
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

	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)

	for id in multiplayer.get_peers():
		add_player(id)

	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
	Signals.level_loaded.emit()

@rpc
func remove_player(player_id):
	if Network.is_networking:
		var player = get_node(str(player_id))
		if is_instance_valid(player):
			player.queue_free()

@rpc
func add_player(player_id):
	if Network.is_networking:

		if Network.connection_count < players.size():
			return

		players.append(player_scene.instantiate())

		var player = players[-1]

		connected_ids.append(player_id)

		player.setposspawn()

		player.device_num = Network.connection_count

		player.name =  str(player_id)
		player.ball_color = Globals.ball_color_dict[Network.connection_count]
		player.player_color = Globals.player_color_dict[Network.connection_count]

		player.player_name = str(player_id)
		player.energys = Globals.energys[Network.connection_count]
		player.score = Globals.score[Network.connection_count]
		player.Hearths = Globals.hearths[Network.connection_count]
		player.deaths = Globals.deaths[Network.connection_count]


		input_maps.append({
			"right{n}".format({"n":Network.connection_count}): Vector2.RIGHT,
			"left{n}".format({"n":Network.connection_count}): Vector2.LEFT,
			"jump{n}".format({"n":Network.connection_count}): null,
			"shoot{n}".format({"n":Network.connection_count}): null,
			"pause{n}".format({"n":Network.connection_count}): null,
			"down{n}".format({"n":Network.connection_count}): null,
		})
		
		player.ui_inputs = input_maps[Network.connection_count]

		Globals._inputs_player(Network.connection_count)

		Network.connection_count += 1

		add_child(player)


func _physics_process(_delta):
	if Globals.autosave:
		DataState.autosave_logic()


