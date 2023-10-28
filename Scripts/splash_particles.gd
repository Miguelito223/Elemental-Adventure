extends Node2D

@onready var timer = $Timer
@onready var particle = $Particles2D

func _ready():
	timer.wait_time = particle.lifetime
	timer.start()

func _on_Timer_timeout():
	#will delete itself on timer timeout
	queue_free()
	pass # Replace with function body.
