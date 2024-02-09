extends Control

@onready var main_menu = $"main menu"
@onready var settings_menu = $"Settings menu"
@onready var online_menu = $"Online Menu"
@onready var graphics_button = $"Settings menu/graphics button"
@onready var autosave_button = $"Settings menu/autosave button"
@onready var time_button = $"Settings menu/time button"
@onready var volumen_button = $"Settings menu/volumen button"
@onready var input_button = $"Settings menu/inputs button"
@onready var multiplayer_button = $"Settings menu/multiplayer button"
@onready var back = $"Settings menu/back"

@onready var graphics_box = $"Settings menu/Graphics"
@onready var autosave_box = $"Settings menu/Autosave"
@onready var time_box = $"Settings menu/time"
@onready var volumen_box = $"Settings menu/Volumen"
@onready var input_box = $"Settings menu/Inputs"
@onready var multiplayer_box = $"Settings menu/Multiplayer"

@onready var host_button = $"Online Menu/host"
@onready var join_button = $"Online Menu/join"

@onready var host_box = $"Online Menu/Host2"
@onready var join_box = $"Online Menu/Join2"


#volumen
@onready var master_volume = $"Settings menu/Volumen/master volume"
@onready var fx_volume = $"Settings menu/Volumen/Fx volume"
@onready var music_volume = $"Settings menu/Volumen/music volume"
#graphics
@onready var fullscreen = $"Settings menu/Graphics/fullscreen tongle"
@onready var FPS = $"Settings menu/Graphics/FPS"
@onready var Vsync = $"Settings menu/Graphics/vsycs"
@onready var graphics = $"Settings menu/Graphics/graphics"
@onready var resolutions = $"Settings menu/Graphics/resolution"

#time
@onready var initial_time = $"Settings menu/time/initial time text"
@onready var time_speed = $"Settings menu/time/time speed text"

#autosave
@onready var autosave = $"Settings menu/Autosave/Autosave"
@onready var autosave_length = $"Settings menu/Autosave/autosave length text"

#inputs
@onready var set_input = $"Settings menu/Inputs/Input_set"
@onready var Mobile_buttons = $"Settings menu/Inputs/Mobile buttons"
@onready var grid = $"Settings menu/Inputs/GridContainer"

#others
@onready var popup = $"Exit Dialog"
@onready var popup2 = $"Remove data Dialog"

#multiplayer
@onready var set_multiplayer_num = $"Settings menu/Multiplayer/player Num text"



var resolution = {
	"2400x1080 ": Vector2i(2400, 1080 ),
	"1920x1080": Vector2i(1920, 1080),
	"1600x900": Vector2i(1600, 900),
	"1440x1080": Vector2i(14400, 1080),
	"1440x900": Vector2i(1440, 900),
	"1366x768": Vector2i(1366, 768),
	"1360x768": Vector2i(1360, 768),
	"1280x1024": Vector2i(1280, 1024),
	"1280x962": Vector2i(1280, 962),
	"1280x960": Vector2i(1280, 960),
	"1280x800": Vector2i(1280, 800),
	"1280x768": Vector2i(1280, 768),
	"1280x720": Vector2i(1280, 720),
	"1176x664": Vector2i(1176, 664),
	"1152x648": Vector2i(1152, 648),
	"1024x768": Vector2i(1024, 768),
	"800x600": Vector2i(800, 600),
	"720x480": Vector2i(720, 480),
}

var inputs = {
	"Keyboard": true,
	"Gamepad": false,
}

var graphic = {
	"potato": 0,
	"low": 1,
	"medium": 2,
	"high": 3,
	"ultra high": 4,
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
	var current_input = Globals.use_keyboard 
	var index = 0
	
	for r in inputs:
		set_input.add_item(r,index)
		
		if inputs[r] == current_input:
			set_input._select_int(index)
		index += 1

func addgraphics():
	var current_input = Globals.Graphics
	var index = 0
	
	for r in graphic:
		graphics.add_item(r,index)
		
		if graphic[r] == current_input:
			graphics._select_int(index)
		index += 1
			
		
func create_action_remap_items():
	if Globals.check_duplicates(Globals.actions_items):
		for i in range(Globals.num_players):
			Globals._clear_inputs_player(i)

		for i in range(Globals.num_players):
			Globals._inputs_player(i)

	else:
		var previus_items 
		if not (grid.get_child_count() - 1) == -1:
			previus_items = grid.get_child(grid.get_child_count() - 1)
		
		for index in range(Globals.actions_items.size()):
			var action = Globals.actions_items[index]
			var label = Label.new()
			label.text = action
			grid.add_child(label)

			var button = RemapButton.new()
			button.action = action
			
			if not previus_items == null and button.is_inside_tree():
				button.focus_neighbor_top = previus_items.get_path()
				previus_items.focus_neighbor_bottom = button.get_path()
			
			if index == Globals.actions_items.size() - 1:
				if not previus_items == null and button.is_inside_tree():
					back.focus_neighbor_top = button.get_path()
					button.focus_neighbor_bottom = back.get_path()
					
			previus_items = button
			grid.add_child(button)
		set_process(false)


func _ready():
	set_process(true)

	
	main_menu.show()
	settings_menu.hide()
	online_menu.hide()
	graphics_box.hide()
	volumen_box.hide()
	autosave_box.hide()
	time_box.hide()
	input_box.hide()
	multiplayer_box.hide()
	graphics_button.show()
	volumen_button.show()
	autosave_button.show()
	time_button.show()
	input_button.show()	
	multiplayer_button.show()
	

	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_create_pressed.call_deferred()

	popup.hide()
	popup2.hide()
	
	addresolutions()
	addinputs()
	addgraphics()

	master_volume.value = Globals.master_volume
	fx_volume.value = Globals.fx_volume
	music_volume.value = Globals.music_volume
	fullscreen.button_pressed = Globals.fullscreen
	Data.load_resolution(Globals.resolution)
	Data.load_graphics(Globals.Graphics)
	initial_time.text = str(Globals.initial_time)
	set_multiplayer_num.text = str(Globals.num_players)
	time_speed.text = str(Globals.time_speed)
	autosave.button_pressed = Globals.autosave
	Mobile_buttons.button_pressed = Globals.use_mobile_buttons
	Vsync.button_pressed = Globals.Vsync
	FPS.button_pressed = Globals.FPS
	autosave_length.text = str(Globals.autosave_length)

func _process(_delta):
	create_action_remap_items()
	
func _on_play_pressed():
	print(Globals.level)
	LoadScene.load_scene(self,Globals.level)
	
func _on_delete_data_pressed():
	popup2.visible = true

	

func _on_option_pressed():
	main_menu.hide()
	settings_menu.show()


func _on_exit_pressed():
	popup.visible = true
	
func _on_master_volume_value_changed(value):
	Data.load_volume(0, value)

func _on_back_pressed():
	if input_box.visible == true or time_box.visible == true or autosave_box.visible == true or graphics_box.visible == true or volumen_box.visible == true or multiplayer_box.visible == true:
		graphics_box.hide()
		volumen_box.hide()
		autosave_box.hide()
		time_box.hide()
		input_box.hide()
		multiplayer_box.hide()
		graphics_button.show()
		volumen_button.show()
		autosave_button.show()
		time_button.show()
		input_button.show()	
		multiplayer_button.show()
	else:
		main_menu.show()
		settings_menu.hide()


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
	Globals.time_speed = int(new_text) 
	Data.save_file()


func _on_initial_time_text_text_changed(new_text):
	Data.load_initial_time(int(new_text))



func _on_autosave_toggled(button_pressed):
	Globals.autosave = button_pressed
	Data.save_file()

func _on_autosave_length_text_text_changed(new_text):
	Globals.autosave_length = int(new_text)
	Data.save_file()


func _on_input_set_item_selected(index):
	var size = inputs.get(set_input.get_item_text(index))
	Data.load_inputs(size)


func _on_mobile_buttons_toggled(button_pressed:bool):
	Globals.use_mobile_buttons = button_pressed
	Data.save_file()


func _on_exit_dialog_confirmed():
	get_tree().quit()


func _on_remove_data_dialog_confirmed():
	DataState.remove_state_file()
	Data.remove_file()
	get_tree().quit()


func _on_graphics_item_selected(index:int):
	var size = graphic.get(graphics.get_item_text(index))
	Data.load_graphics(size)


func _on_fps_toggled(toggled_on:bool):
	Globals.FPS = toggled_on
	Data.save_file()


func _on_vsycs_toggled(toggled_on:bool):
	Globals.Vsync  = toggled_on
	Data.save_file()


func _on_graphics_pressed():
	graphics_box.show()
	volumen_box.hide()
	autosave_box.hide()
	time_box.hide()
	input_box.hide()
	multiplayer_box.hide()
	graphics_button.hide()
	volumen_button.hide()
	autosave_button.hide()
	time_button.hide()
	input_button.hide()
	multiplayer_button.hide()


func _on_inputs_button_pressed():
	graphics_box.hide()
	volumen_box.hide()
	autosave_box.hide()
	time_box.hide()
	input_box.show()
	multiplayer_box.hide()
	graphics_button.hide()
	volumen_button.hide()
	autosave_button.hide()
	time_button.hide()
	input_button.hide()
	multiplayer_button.hide()


func _on_time_button_pressed():
	graphics_box.hide()
	volumen_box.hide()
	autosave_box.hide()
	time_box.show()
	multiplayer_box.hide()
	input_box.hide()
	graphics_button.hide()
	volumen_button.hide()
	autosave_button.hide()
	time_button.hide()
	input_button.hide()
	multiplayer_button.hide()


func _on_volumen_button_pressed():
	graphics_box.hide()
	volumen_box.show()
	autosave_box.hide()
	multiplayer_box.hide()
	time_box.hide()
	input_box.hide()
	graphics_button.hide()
	volumen_button.hide()
	autosave_button.hide()
	time_button.hide()
	input_button.hide()
	multiplayer_button.hide()


func _on_autosave_button_pressed():
	graphics_box.hide()
	volumen_box.hide()
	autosave_box.show()
	time_box.hide()
	input_box.hide()
	multiplayer_box.hide()
	graphics_button.hide()
	volumen_button.hide()
	autosave_button.hide()
	time_button.hide()
	input_button.hide()
	multiplayer_button.hide()



func _on_multiplayer_button_pressed():
	graphics_box.hide()
	volumen_box.hide()
	autosave_box.hide()
	time_box.hide()
	input_box.hide()
	multiplayer_box.show()
	graphics_button.hide()
	volumen_button.hide()
	autosave_button.hide()
	time_button.hide()
	input_button.hide()
	multiplayer_button.hide()


func _on_online_pressed():
	main_menu.hide()
	online_menu.show()


func _on_host_pressed():
	host_box.show()
	join_box.hide()
	host_button.hide()
	join_button.hide()


func _on_join_pressed():
	host_box.hide()
	join_box.show()
	host_button.hide()
	join_button.hide()


func _on_back2_pressed():
	if join_box.visible == true or host_box.visible == true:
		host_box.hide()
		join_box.hide()
		host_button.show()
		join_button.show()
	else:
		main_menu.show()
		online_menu.hide()


func _on_create_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Network.port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	get_parent().multiplayer.multiplayer_peer = peer
	Network.is_networking = true
	if multiplayer.is_server():
		LoadScene.load_scene(self, Globals.map)


func _on_join2_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Network.ip, Network.port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	get_parent().multiplayer.multiplayer_peer = peer
	Network.is_networking = true
	queue_free()

func _on_ip_text_changed(new_text:String):
	Network.ip = new_text

func _on_port_text_changed(new_text:String):
	Network.port = int(new_text)
