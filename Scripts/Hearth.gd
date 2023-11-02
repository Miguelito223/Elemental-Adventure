extends RigidBody2D

var rng = RandomNumberGenerator.new()

var impulse = Vector2(rng.randi_range(-10,10), rng.randi_range(-10,10))

func _on_area_2d_body_entered(body:Node2D):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
			if Globals.hearths[Globals.player_index] < 3:
				body.getlife()
				visible = false
				queue_free()

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"visible": visible,
	}
	return save_dict

func load(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	scale = Vector2(info.size_x, info.size_y)
	visible = info.visible
	
