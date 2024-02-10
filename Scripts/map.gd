extends Node2D

var DEBUGGING = true

var connected_ids: Array = []

var rng = RandomNumberGenerator.new()
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit

var player_scene = preload("res://Scenes/player.tscn")

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))

	if not multiplayer.is_server():
		return

	add_player(1)	

	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)
	get_parent().multiplayer.server_disconnected.connect(server_disconected)
	get_parent().multiplayer.connected_to_server.connect(server_conected)
	get_parent().multiplayer.connection_failed.connect(disconected_fail)
		
		
	Signals.level_loaded.emit()

func _process(_delta):
	await get_tree().create_timer(1).timeout
	Network.count.rpc(connected_ids.size())

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

func add_player(player_id):
	if Network.is_networking:

		print("adding player id: " + str(player_id))

		connected_ids.append(player_id)

		var player = player_scene.instantiate()	

		player.set_multiplayer_authority(player_id)

		player.device_num = Network.connection_count
		player.player_id = player_id

		player.name =  str(player_id)
		player.ball_color = Network.ball_color_dict[player.device_num]
		player.player_color = Network.player_color_dict[player.device_num]

		player.player_name = Network.player_name[player.device_num]
		player.energys = Network.energys[player.device_num]
		player.score = Network.score[player.device_num]
		player.Hearths = Network.hearths[player.device_num]
		player.deaths = Network.deaths[player.device_num]

		Globals._inputs_player(player.device_num)

		player.position = $Marker2D.position

		add_child(player, true)

func remove_player(player_id):
	if Network.is_networking:
		print("removing player id: " + str(player_id))
		var player = get_node(str(player_id))
		connected_ids.erase(player_id)
		if is_instance_valid(player):
			player.queue_free()

func _on_multiplayer_spawner(node:Node):
	if Network.is_networking:
		print("spawned player id: " + str(node.player_id))	
		node.setposspawn()
		
@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)
