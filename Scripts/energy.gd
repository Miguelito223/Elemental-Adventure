extends RigidBody2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
			body.getenergy()
			visible = false
			$"coin sound".play()
			await $"coin sound".finished
			queue_free()

func save_state():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"visible": visible,
	}

func load_state(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	scale = Vector2(info.size_x, info.size_y)
	visible = info.visible



