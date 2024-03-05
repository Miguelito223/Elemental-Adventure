extends DirectionalLight2D

@export var gradient: GradientTexture1D

func _process(_delta):
	var value = (sin(Globals.time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)
	self.enabled = Globals.Graphics
	self.shadow_enabled = Globals.Graphics
	self.shadow_filter = Globals.Graphics
	self.rotation_degrees = 360 - Globals.hour * 15
