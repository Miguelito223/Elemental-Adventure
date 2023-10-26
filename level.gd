extends Node2D

func _ready():
	Data.pos_x = -449
	Data.pos_y = -26
	Data.save_file()

func _on_area_2d_body_entered(body):
	if body.name == "player":
		body.damage(3)


func _on_victory_zone_body_entered(body):
	if body.name == "player":
		Data.level = "level_" + str(int(Data.level) + 1 ) 
		Data.save_file()
		LoadScene.load_scene(self, Data.level)
