extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		Data.coins += 1
		Data.save_file()
		$"coin sound".play()
		visible = false
		await $"coin sound".finished
		queue_free()
