extends Path2D

@export var loop = true
@export var speed = 2.0
@export var speed_scale = 1.0
@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer

func _ready():
	if not loop:
		animation.play("move")
		animation.speed_scale = speed_scale
		set_process(false)

func _process(delta):
	path.progress += speed

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"speed_scale": speed_scale,
		"speed": speed,
		"path_progress": path.progress,
		"path_progress_ratio": path.progress_ratio,
		"loop": loop,

	}
	return save_dict
	
func load(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	scale = Vector2(info.size_x, info.size_y)
	loop = info.loop
	path.progress = info.path_progress
	path.progress_ratio = info.path_progress_ratio
	speed = info.speed
	speed_scale = info.speed_scale

