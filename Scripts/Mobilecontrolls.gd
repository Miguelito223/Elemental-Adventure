extends CanvasLayer

@onready var ui_inputs = get_parent().ui_inputs


# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Network.is_networking:
		if get_parent().is_multiplayer_authority():
			if not Globals.use_mobile_buttons:
				hide()
			else:
				show()
	else:
		if not Globals.use_mobile_buttons:
			hide()
		else:
			show()
