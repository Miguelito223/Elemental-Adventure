extends DirectionalLight2D

var base_angle = 0

@export var gradient: GradientTexture1D

func _ready():
	self.rotation_degrees = 0

func _process(_delta):
	var value = (sin(Globals.time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)
	self.enabled = Globals.Graphics
	self.shadow_enabled = Globals.Graphics
	self.shadow_filter = Globals.Graphics
	self.rotation_degrees = lerpf(self.rotation_degrees, 180 - float(Globals.hour * 15), Globals.time_speed * _delta)

