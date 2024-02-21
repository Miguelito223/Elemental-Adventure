extends ColorRect

@export var gradient: GradientTexture1D

@rpc("any_peer", "call_local")
func set_color_multiplayer(xd):
	self.color = xd

func _process(_delta):
	if Network.is_networking:
		if get_tree().get_multiplayer().is_server():
			var value = (sin(Globals.time - PI / 2) + 1.0 / 2.0)
			self.color = gradient.gradient.sample(value)
			set_color_multiplayer.rpc(self.color)
			await get_tree().create_timer(1).timeout
	else:
		var value = (sin(Globals.time - PI / 2) + 1.0 / 2.0)
		self.color = gradient.gradient.sample(value)

