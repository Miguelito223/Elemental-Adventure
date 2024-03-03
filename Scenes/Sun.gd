extends Node2D

func _process(_delta):
	if Network.is_networking:
		self.visible = is_multiplayer_authority()
	self.rotation_degrees = (Globals.hour * 60) * 0.0166667
