extends Node2D

func _on_area_2d_body_entered(body):
	if body.name == "player":
		body.damage(3)


func _on_victory_zone_body_entered(body):
	if body.name == "player":
		PlayerData.playerdata.level = "level_2"
		Global.load_scene(self, PlayerData.playerdata.level)
		PlayerData.save_file()
