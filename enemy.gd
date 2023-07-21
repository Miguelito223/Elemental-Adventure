extends CharacterBody2D


var SPEED = randi_range(1,3)
var Health = 100
@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
var can_move = true
var direccion = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	setlifes(100)
	$AnimatedSprite2D.play("walk")

func damage(ammount):
	if can_move == true:
		can_move = false
		if InvunerabilityTime.is_stopped():
			$AnimatedSprite2D.stop()
			InvunerabilityTime.start()
			setlifes(Health - ammount)
			Animation_Effects.play("damage")
			Animation_Effects.queue("flash")
			

func setlifes(value):
	Health = clamp(value,0,100)
	print(Health )
	if Health  <= 0:
		print("enemy dead")
		queue_free()

func _process(delta):
	if can_move == true:
		motion(delta)

func motion(delta):
	if direccion == 1:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
	if is_on_wall() or not $"Marker2D/Abajo".is_colliding():
		direccion *= -1
		$"Marker2D/Abajo".scale.x *= -1
		
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x += SPEED * direccion
	
	move_and_slide()

func _on_invunerability_timeout():
	Animation_Effects.play("rest")
	$AnimatedSprite2D.play("walk")
	can_move = true

func _on_area_2d_body_entered(body):
	if body.name == "player":
		body.damage(1)

func _on_area_2d_area_entered(area):
	if area.name == "lavaball":
		damage(10)
