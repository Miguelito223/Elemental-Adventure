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

func save_state():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"speed_scale": speed_scale,
		"speed": speed,
		"path_progress": path.progress,
		"path_progress_ratio": path.progress_ratio,
		"loop": loop,

	}
	return save_dict
	
func load_state(info):
	name = info.name
	loop = info.loop
	path.progress = info.path_progress
	path.progress_ratio = info.path_progress_ratio
	speed = info.speed
	speed_scale = info.speed_scale

