extends CharacterBody2D


var SPEED = randi_range(100,300)
@export var Max_Hearth = 100
@export var hearth = 100
@export var can_move = true
@export var direccion = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer

func _ready():
	setlifes(100)
	$AnimatedSprite2D.play("walk")

func damage(ammount):
	if can_move == true:
		can_move = false
		if InvunerabilityTime.is_stopped():
			$AnimatedSprite2D.stop()
			InvunerabilityTime.start()
			setlifes(hearth - ammount)
			Animation_Effects.play("damage")
			Animation_Effects.queue("flash")
			

func setlifes(value):
	hearth = clamp(value,0,100)
	if hearth  <= 0:
		print("enemy dead")
		queue_free()

func _physics_process(delta):
	if can_move == true:
		motion(delta)

func motion(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_wall() or not $Abajo.is_colliding() and is_on_floor():
		direccion *= -1
		scale.x = -scale.x
	
	velocity.x = SPEED * direccion
	
	move_and_slide()

func _on_invunerability_timeout():
	Animation_Effects.play("rest")
	$AnimatedSprite2D.play("walk")
	can_move = true

func _on_area_2d_body_entered(body):
	if body.get_scene_file_path() == "res://player.tscn":
		body.damage(1)

func _on_area_2d_area_entered(area):
	if area.name == "lavaball":
		damage(10)
		
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"enemy_hearth" : hearth,
		"Max_Hearth" : Max_Hearth,
		"direccion": direccion,
		"can_move": can_move
	}
	return save_dict
	
func load(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	direccion = info.direccion
	can_move = info.can_move
