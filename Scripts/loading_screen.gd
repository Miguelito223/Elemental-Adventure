extends CanvasLayer

signal safe_to_load

func fade_out_loading_screen():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards("fade_in")
	await $AnimationPlayer.animation_finished
	queue_free()
