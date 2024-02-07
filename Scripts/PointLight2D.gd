extends PointLight2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enabled = Globals.Graphics
	shadow_enabled = Globals.Graphics
	shadow_filter = Globals.Graphics
