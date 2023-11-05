extends RigidBody2D

var rng = RandomNumberGenerator.new()

var collected = false

func _ready():
	rng.randomize()

func _on_area_2d_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		if collected == false:
			collected = true
			body.getcoin()
			visible = false
			$"coin sound".play()
			await $"coin sound".finished
			queue_free()

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"collected" : collected,
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
	collected = info.collected



