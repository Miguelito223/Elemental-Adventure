extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		if Data.lifes < 3:
			Data.lifes += 1
			Data.save_file()
			visible = false
			queue_free()
