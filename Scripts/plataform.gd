extends Path2D

@export var loop: bool = true
@export var speed: float = 2.0
@export var speed_scale: float = 1.0
@onready var path = $PathFollow2D
@onready var plataform = $PathFollow2D/RemoteTransform2D
@onready var animation = $AnimationPlayer

func _ready():
	if not loop:
		animation.play("move")
		animation.speed_scale = speed_scale
		set_process(false)

func _process(delta):
	path.progress += speed * delta

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
		"pos_x": position.x,
		"pos_y": position.y,
		"path_pos_x": path.position.x,
		"path_pos_y": path.position.y,
		"curve2D": curve.resource_path,
	}
	return save_dict
	
func load_state(info):
	name = info.name
	curve = load(info.curve2D)
	loop = info.loop
	path.progress = info.path_progress
	path.progress_ratio = info.path_progress_ratio
	speed = info.speed
	speed_scale = info.speed_scale
	path.position.x = info.path_pos_x
	path.position.y = info.path_pos_y
	position.x = info.pos_x
	position.y = info.pos_y
	set_process(true)

