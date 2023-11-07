extends CanvasLayer

@onready var left = $left
@onready var right = $right
@onready var jump = $jump
@onready var shoot = $shoot
@onready var inputs = get_parent().get_parent().inputs


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.use_mobile_buttons:
		hide()
	else:
		show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
