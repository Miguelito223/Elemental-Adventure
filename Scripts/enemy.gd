extends CharacterBody2D

enum {
	walk,
	idle,
	attack
}

@export var Max_Hearth = 20
@export var hearth = 20
@export var can_move = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var marker_node = $Node2D/Marker2D
@onready var marker_node_parent = $Node2D

var state = walk

var can_fire = true

var player

var fancing_right = false

var slimeballs = preload("res://Scenes/fireball.tscn")

var rng = RandomNumberGenerator.new()

var hearths = preload("res://Scenes/hearth.tscn")
var coins = preload("res://Scenes/coin.tscn")

var speed = -100
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
	if hearth <= 0:
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

func flip():
	fancing_right = !fancing_right

	scale.x = abs(scale.x) * -1
	if fancing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func simelball(bullet_direction, bullet_pos, bullet_speed):
	if can_fire:
		var slime_ball = slimeballs.instantiate()
		get_parent().add_child(slime_ball)
		
		slime_ball.get_node("PointLight2D").enabled = false
		slime_ball.get_node("Fire").emitting = false
		slime_ball.modulate = Color("Green")
		
		slime_ball.set_rotation(bullet_direction)
		slime_ball.set_global_position(bullet_pos)
		slime_ball.velocity = Vector2(bullet_speed, 0).rotated(bullet_direction)
		print(marker_node_parent.get_rotation_degrees())
		
		can_fire = false
		await get_tree().create_timer(3).timeout
		can_fire = true

func _physics_process(delta):
	if can_move == true:
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if player:
			marker_node_parent.rotation = (player.global_position - global_position).normalized().angle()

		match state:
			idle:
				$AnimatedSprite2D.animation = "idle"
				velocity.x = 0
			walk:
				
				if is_on_wall() or not $Abajo_detector.is_colliding() and is_on_floor():
					flip()
				
				$AnimatedSprite2D.animation = "walk"
				velocity.x = speed
			attack:
				$AnimatedSprite2D.animation = "attack"
				velocity.x = 0		
				simelball(marker_node_parent.get_rotation(), marker_node.get_global_position(), 500)
		
		move_and_slide()



func _on_invunerability_timeout():
	Animation_Effects.play("rest")
	$AnimatedSprite2D.play("walk")
	can_move = true

func _on_detection_area_2_body_entered(body:Node2D):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		body.damage(1)

func _on_detection_area_body_entered(body:Node2D):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		player = body
		state = attack
		


func _on_detection_area_body_exited(body):
	if body.get_scene_file_path() == "res://Scenes/player.tscn":
		player = null
		state = walk
		
		
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
	}
	return save_dict
	
func load(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	hearth = info.enemy_hearth
