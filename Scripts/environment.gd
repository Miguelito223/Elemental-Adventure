extends Node2D

@onready var paradax_background_1 = $ParallaxBackground
@onready var paradax_background_2 = $ParallaxBackground2
@onready var paradax_background_3 = $ParallaxBackground3

func _process(_delta):
	if Network.is_networking:
		paradax_background_1.visible = true
		paradax_background_2.visible = false
		paradax_background_3.visible = false
	else: 
		if Globals.level_int >= 12 and Globals.level_int < 22 :
			paradax_background_1.visible = false
			paradax_background_2.visible = true
			paradax_background_3.visible = false
		elif Globals.level_int >= 22 and Globals.level_int < 32 :
			paradax_background_1.visible = false
			paradax_background_2.visible = false
			paradax_background_3.visible = true
		else:
			paradax_background_1.visible = true
			paradax_background_2.visible = false
			paradax_background_3.visible = false
