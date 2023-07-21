extends Node

var save_path = "user://SettingsData.json"
var settingsdata = {"volume" : 0, "fullscreen" : false, "resolution": "1920x1080"}

func _ready():
	load_file()

func save_file():
	print("Creating settingsdata file")
	var datafile = FileAccess.open(save_path, FileAccess.WRITE)
	datafile.store_line(JSON.stringify(settingsdata))

func load_file():
	var datafile = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path):
		print("Settingsdata file found")
		settingsdata = JSON.parse_string(datafile.get_line())
	else:
		print("Settingsdata file doesn't exist!")
		save_file()
		
func load_volume(bus, value):
	if value >= 45:
		AudioServer.set_bus_mute(bus,true)
	else:
		AudioServer.set_bus_mute(bus,false)
	AudioServer.set_bus_volume_db(bus,value)
	settingsdata.volume = value
	save_file()
	
func load_fullscreen(value):
	if value == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	settingsdata.fullscreen = value
	save_file()
	
func load_resolution(value):
	DisplayServer.window_set_size(value)
	get_viewport().set_size(value)
	settingsdata.resolution = value
	save_file()
