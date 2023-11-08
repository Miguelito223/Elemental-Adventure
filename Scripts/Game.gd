extends Node

var DEBUGGING = true

var level

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

	await Signals.level_loaded
			
	level = get_node(Globals.level)
	Globals.num_players = Input.get_connected_joypads().size()

	var _ret
	_ret = Input.connect("joy_connection_changed", _on_joy_connection_changed)
	if _ret != 0:
		print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _ret}))



func _on_joy_connection_changed(device_id, connected):
	if DEBUGGING:
		Globals.player_index = device_id
		if connected:
			print("Connected device {d}.".format({"d":Globals.player_index}))
		else:
			print("Disconnected device {d}.".format({"d":Globals.player_index}))
	if connected:
		Globals.num_players = Input.get_connected_joypads().size()
		Globals.player_index = device_id
		if level == null: 
			print("level is null")
			return
		level.add_player()
		print("Added player index {d} to the world.".format({"d":Globals.player_index}))
	else:
		Globals.player_index = device_id
		if level == null: 
			print("level is null")
			return
		level.remove_player()
		print("Removed player index {d} from the world.".format({"d": Globals.player_index}))
