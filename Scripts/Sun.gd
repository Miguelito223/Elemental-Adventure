extends Node2D

func _process(_delta):
	if Network.is_networking:
		self.visible = is_multiplayer_authority()
		self.rotation_degrees = (Globals.hour * 60) / 60
	else:
		self.visible = true
		self.rotation_degrees = (Globals.hour * 60) / 60
