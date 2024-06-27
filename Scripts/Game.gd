extends Node

var DEBUGGING = true
@onready var lineedit = $Chat/LineEdit
@onready var textedit = $Chat/TextEdit

func _ready():
	if DEBUGGING:
		print("Running {n}._ready()... connected joypads: {j}".format({
			"n":name,
			"j": Input.get_connected_joypads()
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}' (Expect 'root')".format({
			"n":name,
			"p":get_parent().name,
			}))
		
	for i in range(Globals.num_players):
		Globals._inputs_player(i)

	Signals.level_loaded.connect(_on_level_loaded)
	Signals.JoinGame.connect(_load_characters_selector)


func _load_characters_selector(ip, port):
	Network.ip = ip
	Network.port = port
	LoadScene.load_scene(null, "res://Scenes/chose_character.tscn")

func _on_level_loaded():

	if Globals.use_keyboard:
		Globals.num_players = 1
	else:
		Globals.num_players = Input.get_connected_joypads().size()

	if Network.is_networking:
		lineedit.visible = true
		textedit.visible = true
	else:
		lineedit.visible = false
		textedit.visible = false	

	var _ret
	_ret = Input.connect("joy_connection_changed", _on_joy_connection_changed)
	if _ret != 0:
		print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _ret}))

	print("Level Loaded")

func _on_joy_connection_changed(device_id, connected):
	if DEBUGGING:
		Globals.player_index = device_id
		if connected:
			print("Connected device {d}.".format({"d":device_id}))
		else:
			print("Disconnected device {d}.".format({"d":device_id}))
	
	if not Network.is_networking:	
		if connected:
			Globals.use_keyboard = false
			
			if Globals.use_keyboard:
				Globals.num_players = 1
			else:
				Globals.num_players = Input.get_connected_joypads().size()
			
			Globals.player_index = device_id
			Globals._clear_inputs_player(device_id)
			Globals._inputs_player(device_id)
			

			if Globals.level_node == null: 
				return

			Globals.level_node.add_player(device_id)
			print("Added player index {d} to the world.".format({"d":device_id}))
		else:
			Globals.use_keyboard = true

			if Globals.use_keyboard:
				Globals.num_players = 1
			else:
				Globals.num_players = Input.get_connected_joypads().size()

			Globals.player_index = device_id
			Globals._clear_inputs_player(device_id)

			if Globals.level_node == null: 
				return

			Globals.level_node.remove_player(device_id)
			print("Removed player index {d} from the world.".format({"d": device_id}))

	else:
		if connected:
			Globals.use_keyboard = false
			Globals._clear_inputs_player(device_id)
			Globals._inputs_player(device_id)
		else:
			Globals.use_keyboard = true
			Globals._clear_inputs_player(device_id)

func _input(event):
	if not Network.is_networking:	
		if event is InputEventJoypadButton:
			if event.button_index == JOY_BUTTON_A:
				if event.is_pressed():
					if not Globals.use_keyboard:
						Globals.num_players = Input.get_connected_joypads().size()
						Globals.player_index = event.device
						Globals._clear_inputs_player(event.device)
						Globals._inputs_player(event.device)

			
						if Globals.level_node == null: 
							return 
							
						Globals.level_node.add_player(event.device)



func _on_multiplayer_spawner_spawned(_node):
	if Network.is_networking:
		if not multiplayer.is_server():
			$Game_Controls.hide()


func _on_map_spawner_despawned(_node):
	if Network.is_networking:
		if not multiplayer.is_server():
			$Game_Controls.show()


func _on_reconnect_pressed():
	if Network.is_networking:
		Network.connected_ids.clear()
		Signals.JoinGame.emit(Network.ip, Network.port)


func _on_back_to_main_menu_pressed():
	if Network.is_networking:
		if not multiplayer.is_server():
			Network.is_networking = false
			Network.connected_ids.clear()
			multiplayer.multiplayer_peer.close()
			$"Main Menu".show()
			$Game_Controls.hide()

@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)
