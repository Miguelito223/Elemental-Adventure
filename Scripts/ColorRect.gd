extends ColorRect

@export var gradient: GradientTexture1D


func _process(_delta):
	if Network.is_networking:
		var value = (sin(Globals.time - PI / 2) + 1.0 / 2.0)
		self.color = gradient.gradient.sample(value)
	else:
		var value = (sin(Globals.time - PI / 2) + 1.0 / 2.0)
		self.color = gradient.gradient.sample(value)

