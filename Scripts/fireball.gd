extends Area2D

var speed = 300
var velocity = Vector2.ZERO

func _physics_process(delta): 
	global_position += transform.x * speed * delta 
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/enemy.tscn":
		body.damage(10)
		var explosion = preload("res://Scenes/explosion.tscn").instantiate()
		get_parent().add_child(explosion)
		explosion.position = position
		explosion.emitting = true
		queue_free()
	else: 
		if body.get_scene_file_path() == "res://Scenes/player.tscn":
			body.damage(1)

		var explosion = preload("res://Scenes/explosion.tscn").instantiate()
		get_parent().add_child(explosion)
		explosion.position = position
		explosion.emitting = true
		queue_free()
		
