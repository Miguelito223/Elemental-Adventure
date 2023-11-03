extends Area2D

var speed = 300

func _physics_process(delta): 
	position += transform.x * speed * delta 


func _on_body_entered(body):
	if body.name == "enemy":
		body.damage(10)
	


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area.name == "Enemy_area":
		area.get_parent().damage(10)
