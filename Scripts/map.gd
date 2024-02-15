extends Node2D

var DEBUGGING = true

var rng = RandomNumberGenerator.new()
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit
@onready var tile_map = $TileMap

var player_scene = preload("res://Scenes/player.tscn")
var enemy_scene = preload("res://Scenes/enemy.tscn")

var enemy_list = []

@onready var timer_wait = 5
@onready var NumEnemys = 10
@onready var MaxEnemies = 30

var timer


func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))

	if not Network.is_networking:
		return
	
	if not get_parent().multiplayer.is_server():
		return

	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", enemys_generation)
	timer.wait_time = timer_wait
	timer.start()
	
	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)
	get_parent().multiplayer.server_disconnected.connect(server_disconected)
	get_parent().multiplayer.connected_to_server.connect(server_conected)
	get_parent().multiplayer.connection_failed.connect(conected_fail)

	if not OS.has_feature("dedicated_server") and get_parent().multiplayer.is_server():
		add_player(1)	
		
	Signals.level_loaded.emit()
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_parent().multiplayer.multiplayer_peer = null

func enemys_generation():

	var enemy = enemy_scene.instantiate()
	var x = randf_range(tile_map.position.x, tile_map.position.x + tile_map.width)
	var y = randf_range(tile_map.position.y, tile_map.position.y + 10)
	enemy.position = Vector2(x, y)
	add_child(enemy, true)
	enemy_list.append(enemy)

	if enemy_list.size() > MaxEnemies:
		timer.stop()

		



func server_disconected():
	print("Server Finish")
	get_parent().multiplayer.multiplayer_peer = null
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")

func conected_fail():
	print("Fail to load")
	get_parent().multiplayer.multiplayer_peer = null
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")

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
	
	if not get_parent().multiplayer.is_server():
		tile_map.request_seeds(1)
	else:
		tile_map.receive_seeds.rpc(tile_map.noise_seed, tile_map.cave_noise_seed,tile_map.rock_noise_seed)




func _on_multiplayer_spawner_spawned(node):
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
		
@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)
