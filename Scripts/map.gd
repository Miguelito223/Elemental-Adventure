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

	if not Network.is_networking:
		return
	

	get_tree().get_multiplayer().server_disconnected.connect(server_disconected)
	get_tree().get_multiplayer().connected_to_server.connect(server_conected)
	get_tree().get_multiplayer().connection_failed.connect(conected_fail)
	get_tree().get_multiplayer().peer_connected.connect(add_player)
	get_tree().get_multiplayer().peer_disconnected.connect(remove_player)

	if not OS.has_feature("dedicated_server") and get_tree().get_multiplayer().is_server():
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

func add_player(peer_id):
	print("adding player id: " + str(peer_id))

	Network.connected_ids.append(peer_id)
	Network.connection_count = Network.connected_ids.size() - 1
	
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
	
	add_child(player, true)
	
	tile_map.receive_seeds.rpc(tile_map.noise_seed, tile_map.cave_noise_seed,tile_map.rock_noise_seed)

		


func _on_player_spawner_spawned(node):
	print("spawning player id: " + node.name)

	Network.connected_ids.append(node.name.to_int())
	Network.connection_count = Network.connected_ids.size() - 1
	
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
	print("removing player id: " + str(peer_id))
	var player = get_node(str(peer_id))
	if is_instance_valid(player):
		Network.connected_ids.erase(player.name.to_int())
		Network.connection_count = Network.connected_ids.size() - 1
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

