extends Node2D

var DEBUGGING = true

var connected_ids: Array = []
var players: Array = []
var input_maps: Array = []

var rng = RandomNumberGenerator.new()
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit

var username: String
var msg: String

var player_scene = preload("res://Scenes/player.tscn")

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
			add_player(Network.connection_count, id)
	)
	get_parent().multiplayer.peer_disconnected.connect(
		func(id):
			remove_player(Network.connection_count, id)
	)

	for id in multiplayer.get_peers():
		add_player(Network.connection_count, id)

	if not OS.has_feature("dedicated_server"):
		add_player(Network.connection_count, 1)
		
	Signals.level_loaded.emit()


func add_player(player_index, player_id):
	if Network.is_networking:

		print("adding player id: " + str(player_id))

		if player_index < players.size():
			return

		players.append(player_scene.instantiate())
		connected_ids.append(player_id)

		var player = players[-1]	

		player.set_multiplayer_authority(player_id)

		player.device_num = player_index
		player.player_id = player_id

		player.name =  str(player_id)
		player.ball_color = Network.ball_color_dict[player_index]
		player.player_color = Network.player_color_dict[player_index]

		player.player_name = Network.player_name[player_index]
		player.energys = Network.energys[player_index]
		player.score = Network.score[player_index]
		player.Hearths = Network.hearths[player_index]
		player.deaths = Network.deaths[player_index]

		Globals._inputs_player(player_index)

		player.position = $Marker2D.position

		add_child(player, true)

func remove_player(player_index, player_id):
	if Network.is_networking:
		print("removing removing id: " + str(player_id))

		var player = players[-1]
		players.remove_at(player_index)
		connected_ids.erase(player_id)
		if is_instance_valid(player):
			player.queue_free()

func _on_multiplayer_spawner(node:Node):
	if Network.is_networking:
		print("adding player id: " + str(node.player_id))

		Network.connection_count += 1
		
		node.setposspawn()
		node.device_num = Network.connection_count

		node.ball_color = Network.ball_color_dict[Network.connection_count]
		node.player_color = Network.player_color_dict[Network.connection_count]

		node.player_name = Network.player_name[Network.connection_count]
		node.energys = Network.energys[Network.connection_count]
		node.score = Network.score[Network.connection_count]
		node.Hearths = Network.hearths[Network.connection_count]
		node.deaths = Network.deaths[Network.connection_count]

func _on_multiplayer_spawner_despawned(node:Node):
	if Network.is_networking:
		print("removing removing id: " + str(node.player_id))
		players.remove_at(Network.connection_count)
		connected_ids.erase(node.player_id)
		Network.connection_count -= 1
		node.queue_free()


@rpc("any_peer", "call_local")
func msg_rcp(username, data):
	textedit.text += str(username,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()
	

func _exit_tree():

	if not multiplayer.is_server():
		return

	get_parent().multiplayer.peer_connected.disconnect(
		func(id):
			add_player(Network.connection_count, id)
	)
	get_parent().multiplayer.peer_disconnected.disconnect(		
		func(id):
			remove_player(Network.connection_count, id)
	)
	



func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(username, lineedit.text)
