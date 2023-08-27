extends CharacterBody2D


var SPEED = randi_range(100,300)
var Health = 100
var can_move = true
var direccion = 1
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
			setlifes(Health - ammount)
			Animation_Effects.play("damage")
			Animation_Effects.queue("flash")
			

func setlifes(value):
	Health = clamp(value,0,100)
	print(Health )
	if Health  <= 0:
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
	if body.name == "player":
		body.damage(1)

func _on_area_2d_area_entered(area):
	if area.name == "lavaball":
		damage(10)
