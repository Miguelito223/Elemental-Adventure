extends Area2D

var speed = 20

func _physics_process(delta:float) -> void:
	var direction = Vector2.RIGHT.rotated(0)
	var velocity = direction * speed
	global_position = velocity * delta
	move_and_collide()
