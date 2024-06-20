extends CanvasLayer

var hearths_size = 1200
@onready var player = get_parent()
@onready var lineedit = $LineEdit
@onready var textedit = $TextEdit


func _ready():
	if not Network.is_networking:
		lineedit.visible = false
		textedit.visible = false
	else:
		lineedit.visible = true
		textedit.visible = true

func _process(_delta):
	update_label()

func update_label():
	$Panel/Hearths.size.x = player.Hearths * hearths_size
	$Panel2/Label2.text = ":" + str(player.energys)
	$Panel3/Label3.text = str(Globals.hour)  + ":" + str(Globals.minute)
	$Panel4/Label4.text =   "Score:" + str(player.score)
	$Panel5/Label.text =   ":" + str(player.deaths)
	$FPS.text =   "FPS:" + str(Engine.get_frames_per_second())  
	$FPS.visible =   Globals.FPS


@rpc("any_peer", "call_local")
func msg_rcp(user, data):
	textedit.text += str(user,  ":", data, "\n")
	lineedit.text = ""
	textedit.scroll_vertical = textedit.get_line_height()

func _on_line_edit_gui_input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		msg_rcp.rpc(Network.username, lineedit.text)
