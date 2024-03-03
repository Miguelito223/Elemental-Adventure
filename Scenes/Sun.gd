extends Node2D

func _process(_delta):
	self.rotation_degree = int(Globals.minute) * 0.0166666667
