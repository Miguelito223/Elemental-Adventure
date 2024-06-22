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
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit

var rng = RandomNumberGenerator.new()

var player_scene = preload("res://Scenes/player.tscn")

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))


	if Network.is_networking:
		lineedit.visible = true
		textedit.visible = true

		multiplayer.server_disconnected.connect(server_disconected)
		multiplayer.connected_to_server.connect(server_conected)
		multiplayer.connection_failed.connect(conected_fail)
		multiplayer.peer_connected.connect(add_network_player)
		multiplayer.peer_disconnected.connect(remove_network_player)

		if multiplayer.is_server():
			for id in multiplayer.get_peers():
				add_network_player(id)

			if not OS.has_feature("dedicated_server"):
				add_network_player(1)
	else:

		lineedit.visible = false
		textedit.visible = false

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


func add_player(player_index):
	if player_index < players.size():
		return

	players.append(player_scene.instantiate())

	var player = players[-1]

	player.setposspawn()

	player.device_num = player_index

	player.name = Globals.player_name[player_index]
	player.ball_color = Globals.ball_color_dict[player_index]
	player.player_color = Globals.player_color_dict[player_index]

	player.player_name = Globals.player_name[player_index]
	player.energys = Globals.energys[player_index]
	player.score = Globals.score[player_index]
	player.Hearths = Globals.hearths[player_index]
	player.deaths = Globals.deaths[player_index]

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
func add_players_list(peer_id):
	players.append(get_node(str(peer_id)))

@rpc("any_peer", "call_local")
func remove_player_list(peer_id):
	players.erase(get_node(str(peer_id)))

func add_network_player(peer_id):
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
	player.device_num = Network.connection_count - 1

	player.player_id = player.name.to_int()

	player.ball_color = Network.ball_color_dict[player.device_num]
	player.player_color = Network.player_color_dict[player.device_num]

	player.player_name = Network.username
	player.energys = Network.energys[player.device_num]
	player.score = Network.score[player.device_num]
	player.Hearths = Network.hearths[player.device_num]
	player.deaths = Network.deaths[player.device_num]

	player.setposspawn()

	Globals._inputs_player(player.device_num)

	add_child(player, true)

	if multiplayer.is_server():
		add_players_list.rpc(peer_id)

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

func _on_player_spawner_despawned(node:Node):
	print("desspawning player id: " + node.name)

func remove_network_player(peer_id):
	var player = get_node(str(peer_id))
	if is_instance_valid(player):
		print("removing player id: " + str(peer_id))
		if multiplayer.is_server():
			Network._remove_player_list.rpc(peer_id)
			remove_player_list.rpc(peer_id)

		player.queue_free()

func _physics_process(_delta):
	if Globals.autosave:
		DataState.autosave_logic()

@rpc("any_peer", "call_local")
func victory_rpc():
	for id in Network.connected_ids:
		print("connected ids array: " + str(id))
		var body = get_node(str(id))
		body.changelevel()
		body.last_position = null
		body.setposspawn()
		remove_network_player(id)

	if Globals.level_int == 31:
		DataState.remove_state_file()
		LoadScene.load_scene(self, "res://Scenes/Super victory screen.tscn")
	else:
		DataState.remove_state_file()
		LoadScene.load_scene(self, "res://Scenes/victory_menu.tscn")


func _on_victory_zone_body_entered(body):
	if body.is_in_group("player"):
		if Network.is_networking:
			if body.is_multiplayer_authority():
				victory_rpc.rpc()
		else:
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


@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)
