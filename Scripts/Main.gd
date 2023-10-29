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

	level = get_tree().get_root().get_node(Globals.level)
	level.num_players = Input.get_connected_joypads().size()

	var _ret
	_ret = Input.connect("joy_connection_changed", _on_joy_connection_changed)
	if _ret != 0:
		print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _ret}))


func _on_joy_connection_changed(device_id, connected):
	if DEBUGGING:
		if connected:
			print("Connected device {d}.".format({"d":device_id}))
		else:
			print("Disconnected device {d}.".format({"d":device_id}))
	if connected:
		level.num_players = Input.get_connected_joypads().size()
		level.add_player(device_id)
		print("Added player index {d} to the world.".format({"d":device_id}))
	else:
		level.remove_player(device_id)
		print("Removed player index {d} from the world.".format({"d":device_id}))
