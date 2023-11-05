extends Control

@onready var main_menu = $"main menu"
@onready var settings_menu = $"settings menu"
@onready var settings_menu2 = $"settings menu2"
@onready var master_volume = $"settings menu/master volume"
@onready var fx_volume = $"settings menu/Fx volume"
@onready var music_volume = $"settings menu/music volume"
@onready var fullscreen = $"settings menu/fullscreen tongle"
@onready var resolutions = $"settings menu/resolution"
@onready var initial_time = $"settings menu/initial time text"
@onready var time_speed = $"settings menu/time speed text"
@onready var autosave = $"settings menu2/Autosave"
@onready var autosave_length = $"settings menu2/autosave length text"
@onready var autosaver_start_time = $"settings menu2/autosaver start time text"
@onready var set_input = $"settings menu2/Input_set"

var resolution = {
	"1920x1080": Vector2i(1920, 1080),
	"1280x720": Vector2i(1280, 720),
	"1152x648": Vector2i(1152, 648),
	"720x480": Vector2i(720, 480)
}

var inputs = {
	"Keyboard": true,
	"Gamepad": false,
}
	
func addresolutions():
	var current_resolution = Globals.resolution
	var index = 0
	
	for r in resolution:
		resolutions.add_item(r,index)
		
		if resolution[r] == current_resolution:
			resolutions._select_int(index)
		index += 1

func addinputs():
	var current_input = Globals.inputs
	var index = 0
	
	for r in inputs:
		set_input.add_item(r,index)
		
		if inputs[r] == current_input:
			set_input._select_int(index)
		index += 1

func _ready():
	main_menu.show()
	settings_menu.hide()
	settings_menu2.hide()
	
	addresolutions()
	addinputs()

	master_volume.value = Globals.master_volume
	fx_volume.value = Globals.fx_volume
	music_volume.value = Globals.music_volume
	fullscreen.button_pressed = Globals.fullscreen
	Data.load_resolution(Globals.resolution)
	initial_time.text = Globals.initial_time
	time_speed.text = Globals.time_speed
	autosave.button_pressed = Globals.autosave
	autosave_length.text = Globals.autosave_length
	autosaver_start_time.text = Globals.autosaver_start_time
	
func _on_play_pressed():
	print(Globals.level)
	LoadScene.load_scene(self,Globals.level)
	
func _on_delete_data_pressed():
	DataState.remove_state_file()
	Data.remove_file()
	DataState.node_data_load.clear()
	DataState.node_data_save.clear()

	

func _on_option_pressed():
	main_menu.hide()
	settings_menu.show()
	settings_menu2.hide()


func _on_exit_pressed():
	get_tree().quit()
	
func _on_master_volume_value_changed(value):
	Data.load_volume(0, value)

func _on_back_pressed():
	main_menu.show()
	settings_menu.hide()
	settings_menu2.hide()

func _on_fullscreen_tongle_toggled(button_pressed):
	Data.load_fullscreen(button_pressed)

func _on_option_button_item_selected(index):
	var size = resolution.get(resolutions.get_item_text(index))
	Data.load_resolution(size)


func _on_fx_volume_value_changed(value):
	Data.load_volume(2, value)


func _on_music_volume_value_changed(value):
	Data.load_volume(1, value)


func _on_time_speed_text_text_changed(new_text):
	Globals.time_speed = new_text 
	Data.save_file()


func _on_initial_time_text_text_changed(new_text):
	Globals.initial_time = new_text 
	Data.save_file()


func _on_continue_pressed():
	main_menu.hide()
	settings_menu.hide()
	settings_menu2.show()


func _on_back_2_pressed():
	main_menu.hide()
	settings_menu.show()
	settings_menu2.hide()


func _on_autosave_toggled(button_pressed):
	Globals.autosave = button_pressed
	Data.save_file()

func _on_autosave_length_text_text_changed(new_text):
	Globals.autosave_length = new_text
	Data.save_file()

func _on_autosaver_start_time_text_text_changed(new_text):
	Globals.autosaver_start_time = new_text
	Data.save_file()


func _on_input_set_item_selected(index):
	var size = inputs.get(set_input.get_item_text(index))
	Data.load_inputs(size)
