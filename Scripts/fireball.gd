extends Area2D

var speed = 300
var velocity = Vector2.ZERO

func _physics_process(delta): 
	position += velocity * delta 
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area.get_scene_file_path() == "res://Scenes/enemy.tscn":
		area.get_parent().damage(10)
		queue_free()

func _on_body_entered(body):
	if body.get_scene_file_path() == "res://Scenes/enemy.tscn":
		body.damage(10)
		queue_free()
	else: 
		if body.get_scene_file_path() == "res://Scenes/player.tscn":
			return

			
		queue_free()
		
