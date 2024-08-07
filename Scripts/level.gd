extends Node2D

var DEBUGGING = true

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

	Globals.level_node = self

	DataState.load_file_state()

	if Network.is_networking:
		multiplayer.server_disconnected.connect(server_disconected)
		multiplayer.connected_to_server.connect(server_conected)
		multiplayer.connection_failed.connect(conected_fail)
		multiplayer.peer_connected.connect(add_network_player)
		multiplayer.peer_disconnected.connect(remove_network_player)

		if multiplayer.is_server():
			if not OS.has_feature("dedicated_server"):
				add_network_player(1)
			
			for id in multiplayer.get_peers():
				add_network_player(id)
	else:
		for player in range(Globals.num_players):
			if Globals.num_players > 4:
				print("no more of four players")
				return 
				
			add_player(player)

		if Globals.num_players == 0:
			for player in range(1):
				add_player(player)

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


func remove_player(player_index):
	var player = players[-1]
	players.remove_at(player_index)
	if is_instance_valid(player):
		player.queue_free()
		
func server_disconected():
	print("Server Finish")
	Network.multiplayer_peer_Enet_host.destroy()
	multiplayer.multiplayer_peer = null
	Network.is_networking = false
	Network.connected_ids.clear()
	UnloadScene.unload_scene(self)
	get_parent().get_node("Main Menu").show()

func conected_fail():
	print("Fail to load")
	Network.multiplayer_peer_Enet_host.destroy()
	multiplayer.multiplayer_peer = null
	Network.is_networking = false
	Network.connected_ids.clear()
	UnloadScene.unload_scene(self)
	get_parent().get_node("Main Menu").show()

func server_conected():
	print("Server Conected")
	Network.is_networking = true


func add_player(player_index):
	if player_index < players.size():
		return

	players.append(player_scene.instantiate())

	var player = players[-1]

	player.device_num = player_index
	player.setposspawn()

	if DataState.node_data.is_empty():
		print("node data is empy")
		player.setposspawn()
	else: 
		print("node data is not empy")
		for i in DataState.node_data:
			var node_data = DataState.node_data[i]
			if node_data.filename == "res://Scenes/player.tscn":
				if node_data.device_num == player_index or node_data.player_name == player.player_name:
					print(node_data)
					player.load_state(node_data)

	Globals._inputs_player(player_index)

	add_child(player)

@rpc("any_peer", "call_local")
func sync_all_players_list():
	# Actualizar la lista de jugadores en todos los clientes
	print("Syncring player list")
	Network.connected_ids.clear()
	players.clear()
	
	for player in get_tree().get_nodes_in_group("player"):
		Network.connected_ids.append(player.name.to_int())

	Network.connection_count = Network.connected_ids.size()
	players = get_tree().get_nodes_in_group("player")
	


func add_network_player(peer_id):
	print("adding player id: " + str(peer_id))

	if OS.get_name() == "Web":
		Network.multiplayer_peer_websocker_peer = Network.multiplayer_peer_websocker.get_peer(peer_id)
	else:
		Network.multiplayer_peer_Enet_peer = Network.multiplayer_peer_Enet.get_peer(peer_id)
		if Network.multiplayer_peer_Enet_peer != null:
			Network.multiplayer_peer_Enet_peer.set_timeout(60000, 300000, 600000)
	
	var player = player_scene.instantiate()
	
	player.name = str(peer_id)
	player.player_id = player.name.to_int()
	player.device_num = Globals.player_index
	player.setposspawn()

	Globals._inputs_player(player.device_num)

	add_child(player, true)
	
	sync_all_players_list.rpc()
		

func remove_network_player(peer_id):
	print("removing player id: " + str(peer_id))	
	var player = get_node_or_null(str(peer_id))
	if player and is_instance_valid(player):
		player.queue_free()
		await player.tree_exited
		sync_all_players_list.rpc()
	else:
		print("Player node not found or already freed: " + str(peer_id))
		sync_all_players_list.rpc()

	

func _on_player_spawner_spawned(node):
	print("spawning player id: " + node.name)
	node.player_id = node.name.to_int()
	node.device_num = Globals.player_index
	node.setposspawn()
	sync_all_players_list.rpc()

func _on_player_spawner_despawned(node:Node):
	print("desspawning player id: " + node.name)
	sync_all_players_list.rpc()

func _physics_process(_delta):
	if Globals.autosave:
		DataState.autosave_logic()

@rpc("any_peer", "call_local")
func victory_rpc():
	for id in Network.connected_ids:
		var body = get_node(str(id))
		if is_instance_valid(body):
			body.changelevel()
			body.last_position = null
			body.setposspawn()
			remove_network_player(id)

	DataState.remove_state_file()

	if (Globals.level_int - 1) == 31:
		LoadScene.load_scene(self, "res://Scenes/Super victory screen.tscn")
	else:
		LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")


func _on_victory_zone_body_entered(body):
	if body.is_in_group("player"):
		if Network.is_networking:
			if body.is_multiplayer_authority():
				victory_rpc.rpc()
		else:
			if body.device_num == 0:
				body.changelevel()
				body.last_position = null
				body.setposspawn()

				DataState.remove_state_file()

				if (Globals.level_int - 1) == 31:
					LoadScene.load_scene(self, "res://Scenes/Super victory screen.tscn")
				else:
					LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")
			else:
				remove_player(body.device_num)



