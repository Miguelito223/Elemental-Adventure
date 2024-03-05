extends DirectionalLight2D

var base_angle = 0

@export var gradient: GradientTexture1D

func _process(_delta):
	var value = (sin(Globals.time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)
	self.enabled = Globals.Graphics
	self.shadow_enabled = Globals.Graphics
	self.shadow_filter = Globals.Graphics
<<<<<<< HEAD
	self.rotation_degrees = 180 - (Globals.hour * 15)
=======
	self.rotation_degrees = 360 - Globals.hour * 15
>>>>>>> c37716f59e442cc29d52a9442edd4ce0517d031a
