extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		PlayerData.playerdata.coins += 1
		GameData.gamedata.coins_map -= 1
		PlayerData.save_file()
		$"coin sound".play()
		visible = false
		await $"coin sound".finished
		queue_free()
