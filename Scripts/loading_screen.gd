extends CanvasLayer

signal safe_to_load

@onready var Progress_bar = $Control/ProgressBar

func update_progress_bar(new_value: float):
	Progress_bar.set_value_no_signal(new_value * 100)

func fade_out_loading_screen():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards("fade_in")
	await $AnimationPlayer.animation_finished
	queue_free()
