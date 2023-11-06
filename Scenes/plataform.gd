extends AnimatableBody2D

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"size_x" : scale.x,
		"size_y" : scale.y,
	}
	return save_dict
	
func load(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	scale = Vector2(info.size_x, info.scale.y)
