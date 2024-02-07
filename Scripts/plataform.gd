extends Path2D

@export var loop: bool = true
@export var speed = 2
@export var speed_scale = 1
@onready var pathfollow = $PathFollow2D
@onready var plataform = $PathFollow2D/RemoteTransform2D
@onready var animationplayer = $AnimationPlayer
@onready var animation = "move"

func _ready():
	if not loop:
		animationplayer.play("move")
		animationplayer.speed_scale = speed_scale
		set_process(false)

func _process(_delta):
	pathfollow.progress += speed

func save_state():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"speed_scale": speed_scale,
		"speed": speed,
		"path_progress": pathfollow.progress,
		"path_progress_ratio": pathfollow.progress_ratio,
		"path_pos_x": pathfollow.position.x,
		"path_pos_y": pathfollow.position.y,
		"loop": loop,
		"pos_x": position.x,
		"pos_y": position.y,
		"curve2D": curve.resource_path,
		"Animation_track_count": animationplayer.get_animation(animation).get_track_count(),
		"Animation_key_count": animationplayer.get_animation(animation).track_get_key_count(animationplayer.get_animation(animation).get_track_count()),
		"Animation_time": animationplayer.get_animation(animation).track_get_key_time(animationplayer.get_animation(animation).get_track_count(), animationplayer.get_animation(animation).track_get_key_count(animationplayer.get_animation(animation).get_track_count())),
	}
	return save_dict
	
func load_state(info):
	name = info.name
	curve = load(info.curve2D)
	loop = info.loop
	position = Vector2(info.pos_x, info.pos_y)
	speed = info.speed
	speed_scale = info.speed_scale
	pathfollow.progress = info.path_progress
	pathfollow.progress_ratio = info.path_progress_ratio
	pathfollow.position = Vector2(info.path_pos_x, info.path_pos_y)
	animationplayer.get_animation(animation).track_set_key_time(info.Animation_track_count, info.Animation_key_count, info.Animation_time)



