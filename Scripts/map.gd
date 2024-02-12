extends Node2D

var DEBUGGING = true

var rng = RandomNumberGenerator.new()
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit
@onready var tile_map = $TileMap

var player_scene = preload("res://Scenes/player.tscn")
var enemy_scene = preload("res://Scenes/enemy.tscn")

var rand = RandomNumberGenerator.new()

@export var timer = 10
@export var NumEnemys = 10

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))

	if not Network.is_networking:
		return
		
	enemys_generation()

	if not get_parent().multiplayer.is_server():
		return

	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)
	get_parent().multiplayer.server_disconnected.connect(server_disconected)
	get_parent().multiplayer.connected_to_server.connect(server_conected)
	get_parent().multiplayer.connection_failed.connect(disconected_fail)

	if not OS.has_feature("dedicated_server") and get_parent().multiplayer.is_server():
		add_player(1)
		
		
	Signals.level_loaded.emit()
	

func enemys_generation():
	while true:
		await get_tree().create_timer(timer).timeout
		for i in range(1, NumEnemys):
			await get_tree().create_timer(5).timeout
			var enemy = enemy_scene.instantiate()
			rand.randomize()
			var x = rand.randf_range(tile_map.position.y, tile_map.position.y + 1000)
			rand.randomize()
			var y = rand.randf_range(tile_map.position.x, tile_map.position.x + 1000)
			enemy.position = Vector2(x, y)
			add_child(enemy)

func server_disconected():
	print("Server Finish")
	get_parent().multiplayer.multiplayer_peer = null
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")

func disconected_fail():
	print("Fail to load")
	get_parent().multiplayer.multiplayer_peer = null
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")

func server_conected():
	
	print("Server Started")

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
	Network.erase_connected_ids.rpc(peer_id)
	Network.set_connected_ids_number.rpc()
	if is_instance_valid(player):
		player.queue_free()
		
@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)


