extends CharacterBody2D


var speed = 100
@export var Max_Hearth = 20
@export var hearth = 20
@export var can_move = true
@export var direccion = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer

var player_chase = false
var player = null

var rng = RandomNumberGenerator.new()

var hearths = preload("res://Scenes/hearth.tscn")
var coins = preload("res://Scenes/coin.tscn")

var max_speed = 70
var max_speed_in_air = 60
var max_speed_in_water = 20

func _ready():
	setlifes(hearth)
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

func drop_hearths():
	var new_hearth = hearths.instantiate()
	get_parent().add_child(new_hearth)
	new_hearth.position = position
	new_hearth.freeze = false

	
func drop_coins():
	var new_coin = coins.instantiate()
	get_parent().add_child(new_coin)
	new_coin.position = position
	new_coin.freeze = false
			

func setlifes(value):
	hearth = clamp(value,0,20)
	if hearth  <= 0:
		print("enemy dead")
		rng.randomize()
		var random_number = rng.randi_range(0,  5)
		var random_number2 = rng.randi_range(0,  10)
		if random_number == 5:
			drop_coins()
		if random_number2 == 10:
			drop_hearths()
		Globals.score += 3
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
	
	if not player_chase:
		velocity.x = direccion * speed
	else:
		position += (player.position - position)/speed

		if (player.position.x - position.x) < 0 :
			scale.x = -scale.x
		else:
			scale.x = scale.x


	if is_on_floor():
		velocity.x = velocity.limit_length(max_speed).x
	else:
		velocity.x = velocity.limit_length(max_speed_in_air).x


	move_and_slide()

func _on_invunerability_timeout():
	Animation_Effects.play("rest")
	$AnimatedSprite2D.play("walk")
	can_move = true

func _on_area_2d_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		player = body
		player_chase = true

func _on_detection_area_body_exited(body:Node2D):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		player = null
		player_chase = false
		
func in_water():
	damage(10)
	gravity = gravity / 3
	max_speed = max_speed_in_water
		
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



