extends Node

var DEBUGGING = true

signal JoinGame(ip,port)

var level
var map

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

	await Signals.level_loaded	
	if Network.is_networking:
		map = get_node(Globals.map)
	else:
		level = get_node(Globals.level)
	
	
	if Globals.use_keyboard:
		Globals.num_players = 1
	else:
		Globals.num_players = Input.get_connected_joypads().size()
	

	var _ret
	_ret = Input.connect("joy_connection_changed", _on_joy_connection_changed)
	if _ret != 0:
		print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _ret}))
		



func _on_joy_connection_changed(device_id, connected):
	if DEBUGGING:
		Globals.player_index = device_id
		if connected:
			print("Connected device {d}.".format({"d":device_id}))
		else:
			print("Disconnected device {d}.".format({"d":device_id}))
	if connected:
		Globals.use_keyboard = false
		
		if Globals.use_keyboard:
			Globals.num_players = 1
		else:
			Globals.num_players = Input.get_connected_joypads().size()
		
		Globals.player_index = device_id

		Globals._clear_inputs_player(device_id)
		Globals._inputs_player(device_id)
		

		if level == null: 
			return

		level.add_player(device_id)
		print("Added player index {d} to the world.".format({"d":device_id}))
	else:
		Globals.use_keyboard = true

		if Globals.use_keyboard:
			Globals.num_players = 1
		else:
			Globals.num_players = Input.get_connected_joypads().size()

		Globals.player_index = device_id
		Globals._clear_inputs_player(device_id)

		if level == null: 
			return

		level.remove_player(device_id)
		print("Removed player index {d} from the world.".format({"d": device_id}))

func _input(event):
	if event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_A:
			if event.is_pressed():
				if not Globals.use_keyboard:
					Globals.num_players = Input.get_connected_joypads().size()
					Globals.player_index = event.device
					Globals._clear_inputs_player(event.device)
					Globals._inputs_player(event.device)

		
					if level == null: 
						return 
						
					level.add_player(event.device)



func _on_multiplayer_spawner_spawned(_node):
	if Network.is_networking:
		if not get_tree().get_multiplayer().is_server():
			get_node("CanvasLayer").hide()


func _on_map_spawner_despawned(_node):
	if Network.is_networking:
		if not get_tree().get_multiplayer().is_server():
			get_node("CanvasLayer").show()


func _on_reconnect_pressed():
	if Network.is_networking:
		Network.connected_ids.clear()
		JoinGame.emit(Network.ip, Network.port)


func _on_back_to_main_menu_pressed():
	if Network.is_networking:
		if not get_tree().get_multiplayer().is_server():
			Network.is_networking = false
			Network.connected_ids.clear()
			get_tree().get_multiplayer().multiplayer_peer.close()
			get_node("Main Menu").show()
			get_node("CanvasLayer").hide()
