extends Area2D

var explosion = preload("res://Scenes/explosion.tscn").instantiate()
var velocity = Vector2.ZERO

func _physics_process(delta): 
	global_position += velocity * delta 
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.damage(20)
		
		get_parent().add_child(explosion)
		explosion.position = position
		explosion.emitting = true
		queue_free()
		await get_tree().create_timer(5).timeout
		explosion.queue_free()
		
	else: 
		if body.is_in_group("player"):
			body.damage(0.5)

		get_parent().add_child(explosion)
		explosion.position = position
		explosion.emitting = true
		queue_free()
		await get_tree().create_timer(5).timeout
		explosion.queue_free()
		
