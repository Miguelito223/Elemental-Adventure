extends Node2D

func _on_area_2d_body_entered(body):
	if body.name == "player":
		body.damage(3)


func _on_victory_zone_body_entered(body):
	if body.name == "player":
		Data.data.player_data.level = "level_" + str( int(Data.data.player_data.level) + 1 ) 
		Data.save_file()
		Global.load_scene(self, Data.data.player_data.level)
