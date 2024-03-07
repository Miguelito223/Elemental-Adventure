extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.rotation_degrees = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.rotation_degrees = lerpf(self.rotation_degrees, float(Globals.hour * -15), Globals.time_speed * _delta)
