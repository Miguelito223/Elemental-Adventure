extends Node2D

var DEBUGGING = true

var rng = RandomNumberGenerator.new()
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit
@onready var tile_map = $TileMap

var player_scene = preload("res://Scenes/player.tscn")

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))

	if Network.is_networking:
		multiplayer.server_disconnected.connect(server_disconected)
		multiplayer.connected_to_server.connect(server_conected)
		multiplayer.connection_failed.connect(conected_fail)
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(remove_player)

		if multiplayer.is_server():
			if not OS.has_feature("dedicated_server"):
				add_player(1)	
		
	Signals.level_loaded.emit()

func server_disconected():
	print("Server Finish")
	Network.is_networking = false
	Network.connected_ids.clear()
	UnloadScene.unload_scene(self)
	get_parent().get_node("Main Menu").show()

func conected_fail():
	print("Fail to load")
	Network.is_networking = false
	Network.connected_ids.clear()
	UnloadScene.unload_scene(self)
	get_parent().get_node("Main Menu").show()

func server_conected():
	print("Server Conected")
	Network.is_networking = true

func add_player(peer_id):
	print("adding player id: " + str(peer_id))
	
	if multiplayer.is_server():
		Network._add_player_list.rpc(peer_id)


	if OS.get_name() == "Web":
		Network.multiplayer_peer_websocker_peer = Network.multiplayer_peer_websocker.get_peer(peer_id)
	else:
		Network.multiplayer_peer_Enet_peer = Network.multiplayer_peer_Enet.get_peer(peer_id)
		if Network.multiplayer_peer_Enet_peer != null:
			Network.multiplayer_peer_Enet_peer.set_timeout(60000, 300000, 600000)
	
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.device_num = Network.connection_count

	player.player_id = player.name.to_int()

	player.player_name = Network.username
	player.ball_color = Network.ball_color_dict[player.device_num]
	player.player_color = Network.player_color_dict[player.device_num]

	player.player_name = Network.username
	player.energys = Network.energys[player.device_num]
	player.score = Network.score[player.device_num]
	player.Hearths = Network.hearths[player.device_num]
	player.deaths = Network.deaths[player.device_num]

	Globals._inputs_player(player.device_num)
	
	if multiplayer.is_server():
		tile_map.receive_seeds.rpc_id(peer_id, tile_map.noise_seed, tile_map.cave_noise_seed,tile_map.rock_noise_seed)

	add_child(player, true)

		


func _on_player_spawner_spawned(node):
	print("spawning player id: " + node.name)
	
	node.device_num = Network.connection_count
	node.player_id = node.name.to_int()

	node.ball_color = Network.ball_color_dict[node.device_num]
	node.player_color = Network.player_color_dict[node.device_num]

	node.player_name = Network.username
	node.energys = Network.energys[node.device_num]
	node.score = Network.score[node.device_num]
	node.Hearths = Network.hearths[node.device_num]
	node.deaths = Network.deaths[node.device_num]


func remove_player(peer_id):
	var player = get_node(str(peer_id))
	if is_instance_valid(player):
		print("removing player id: " + str(peer_id))
		if multiplayer.is_server():
			Network._remove_player_list.rpc(peer_id)

		player.queue_free()


func _on_player_spawner_despawned(node:Node):
	print("desspawning player id: " + node.name)

		
@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)

