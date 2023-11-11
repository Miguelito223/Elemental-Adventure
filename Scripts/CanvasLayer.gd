extends CanvasLayer

var hearths_size = 1200


# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()
	Globals.hud = self

func _process(delta):
	update_label()
	

func update_label():
	$Panel/Hearths.size.x = Globals.hearths[str(0)] * hearths_size
	$Panel2/Label2.text = ":" + str(Globals.coins)
	$Panel3/Label3.text = str(Globals.hour)  + ":" + str(Globals.minute)
	$Panel4/Label4.text =   "Score:" + str(Globals.score)
