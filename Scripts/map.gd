extends Node2D

var DEBUGGING = true

var connected_ids: Array = []
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
		

	get_parent().multiplayer.peer_connected.connect(add_player)
	get_parent().multiplayer.peer_disconnected.connect(remove_player)

	for id in multiplayer.get_peers():
		add_player(id)

	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
	Signals.level_loaded.emit()


func add_player(player_id):
	if Network.is_networking:

		print("adding player id: " + str(player_id))

		Network.connection_count += 1

		connected_ids.append(player_id)

		var player = player_scene.instantiate()	

		player.set_multiplayer_authority(player_id)

		player.device_num = Network.connection_count
		player.player_id = player_id

		player.name =  str(player_id)
		player.ball_color = Network.ball_color_dict[Network.connection_count]
		player.player_color = Network.player_color_dict[Network.connection_count]

		player.player_name = Network.player_name[Network.connection_count]
		player.energys = Network.energys[Network.connection_count]
		player.score = Network.score[Network.connection_count]
		player.Hearths = Network.hearths[Network.connection_count]
		player.deaths = Network.deaths[Network.connection_count]

		Globals._inputs_player(Network.connection_count)

		player.position = $Marker2D.position

		add_child(player, true)

func remove_player(player_id):
	if Network.is_networking:
		print("removing removing id: " + str(player_id))
		var player = get_node(str(player_id))
		connected_ids.erase(player_id)
		if is_instance_valid(player):
			player.queue_free()

func _on_multiplayer_spawner(node:Node):
	if Network.is_networking:
		print("spawned player id: " + str(node.player_id))	
		node.setposspawn()


@rpc("any_peer", "call_local")
func msg_rcp(username, data):
	textedit.text += str(username,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()
	

func _exit_tree():

	if not multiplayer.is_server():
		return

	get_parent().multiplayer.peer_connected.disconnect(add_player)
	get_parent().multiplayer.peer_disconnected.disconnect(remove_player)
	



func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(username, lineedit.text)
