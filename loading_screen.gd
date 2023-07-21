extends CanvasLayer

signal safe_to_load

@onready var animplayer = $AnimationPlayer

func fade_out_loading_screen():
	animplayer.play("fade_in")
	await animplayer.animation_finished
	animplayer.play_backwards("fade_in")
	await animplayer.animation_finished
	queue_free()
