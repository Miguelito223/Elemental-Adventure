extends Node2D

func _process(_delta):
	self.rotation_degrees = (Globals.hour * 60) * 0.0166666667
