extends Node2D

var DEBUGGING = true

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

	if not Network.is_networking:
		return

	if not get_parent().multiplayer.is_server():
		return

	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)
	get_parent().multiplayer.server_disconnected.connect(server_disconected)
	get_parent().multiplayer.connected_to_server.connect(server_conected)
	get_parent().multiplayer.connection_failed.connect(disconected_fail)

	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
	Signals.level_loaded.emit()



func server_disconected():
	print("Server Finish")
	get_parent().multiplayer.multiplayer_peer = null
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")

func disconected_fail():
	print("Fail to load")
	get_parent().multiplayer.multiplayer_peer = null
	LoadScene.load_scene(self, "res://Scenes/main_menu.tscn")

func server_conected():
	LoadScene.load_scene(null, self)
	print("Server Started")

func add_player(peer_id):
	print("adding player id: " + str(peer_id))

	Network.connected_ids.append(peer_id)

	Network.connection_count += 1


	var player = player_scene.instantiate()	

	player.set_multiplayer_authority(peer_id)

	player.setposspawn()

	player.device_num = Network.connection_count
	player.player_id = peer_id

	player.name = str(peer_id)
	player.ball_color = Network.ball_color_dict[Network.connection_count]
	player.player_color = Network.player_color_dict[Network.connection_count]

	player.player_name = Network.username
	player.energys = Network.energys[Network.connection_count]
	player.score = Network.score[Network.connection_count]
	player.Hearths = Network.hearths[Network.connection_count]
	player.deaths = Network.deaths[Network.connection_count]

	Globals._inputs_player(Network.connection_count)
	
	add_child(player, true)

	


func remove_player(peer_id):
	print("removing player id: " + str(peer_id))
	var player = get_node(str(peer_id))
	Network.connected_ids.erase(peer_id)
	Network.connection_count -= 1
	if Network.connection_count < 0:
		Network.connection_count = 0
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
