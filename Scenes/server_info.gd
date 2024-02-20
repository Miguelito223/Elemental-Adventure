extends HBoxContainer

func _on_join_pressed():
	var error = Network.multiplayer_peer_client.create_client("ws://" + get_node("ip").text + ":" + get_node("port").text )
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = Network.multiplayer_peer_client
		Network.is_networking = true
		if not get_tree().get_multiplayer().is_server():
			get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().hide()
			LoadScene.load_scene(null, "res://Scenes/game.tscn")
	else:
		push_error("Error creating client: ", str(error))
