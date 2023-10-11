extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		if Data.data.player_data.lifes < 3:
			Data.data.player_data.lifes += 1
			Data.save_file()
			visible = false
			queue_free()
