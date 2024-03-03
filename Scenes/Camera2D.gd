extends Camera2D

func _process(_delta):
	if Network.is_networking:
		$Environment.visible = true
	else: 
		$Environment.visible = false
