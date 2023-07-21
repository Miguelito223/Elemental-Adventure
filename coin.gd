extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		PlayerData.playerdata.coins += 1
		$coin.play()
		PlayerData.save_file()
		queue_free()
