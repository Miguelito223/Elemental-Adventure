extends Node

signal finish_remove_data
signal finish_add_data
signal finish_load_data

var data_path = "user://Data.json"
var data = {}

func _ready():
	load_file()

#setting saver
func save_file():
	print("Creating data file")
	data = {
		"settings":{
			"master_volume": Globals.master_volume, 
			"fx_volume":  Globals.fx_volume, 
			"music_volume":  Globals.music_volume, 
			"fullscreen":  Globals.fullscreen, 
			"resolution":  Globals.resolution, 
			"initial_time":  Globals.initial_time, 
			"time_speed":  Globals.time_speed,
			"autosave":  Globals.autosave,
			"autosave_length":  Globals.autosave_length,
			"autosaver_start_time":  Globals.autosaver_start_time,
		},
		"time":{
			"day": Globals.day,
			"hour": Globals.hour,
			"minute":Globals.minute
		}
	}
	var datafile = FileAccess.open(data_path, FileAccess.WRITE)
	datafile.store_line(JSON.stringify(data))
	
	finish_add_data.emit()
	
	print("finish")

func load_file():
	print("loading data...")
	var datafile = FileAccess.open(data_path, FileAccess.READ)
	if FileAccess.file_exists(data_path):
		print("Data file found")
		while datafile.get_position() < datafile.get_length():
			
			data = JSON.parse_string(datafile.get_line())
			
			var settings = data.settings
			
			#settings
			Globals.master_volume = settings.master_volume
			Globals.fx_volume = settings.fx_volume
			Globals.music_volume = settings.music_volume
			Globals.fullscreen = settings.fullscreen
			Globals.resolution = str_to_var("Vector2i" + settings.resolution)
			Globals.initial_time = settings.initial_time
			Globals.time_speed = settings.time_speed
			Globals.autosave = settings.autosave
			Globals.autosave_length = settings.autosave_length
			Globals.autosaver_start_time = settings.autosaver_start_time

			var time = data.time

			Globals.day = time.day
			Globals.hour = time.hour
			Globals.minute = time.minute
			
			finish_load_data.emit()
			print("finish")

	else:
		print("Data file doesn't exist!")
		save_file()
		
		
#Player and other save
		

	
func remove_file():
	print("Removing file...")
	if FileAccess.file_exists(data_path):
		DirAccess.remove_absolute(data_path)
	finish_remove_data.emit()
	print("finish")
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_file()

func load_volume(bus, value):
	if value >= 45:
		AudioServer.set_bus_mute(bus,true)
	else:
		AudioServer.set_bus_mute(bus,false)
	
	match bus:
		0:
			Globals.master_volume = value
		1:
			Globals.music_volume = value
		2:
			Globals.fx_volume = value
			
	AudioServer.set_bus_volume_db(bus,value)
	
	save_file()
	
func load_fullscreen(value):
	if value == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Globals.fullscreen = value
	save_file()
	
func load_resolution(value):
	DisplayServer.window_set_size(value)
	get_viewport().set_size(value)
	Globals.resolution = value
	save_file()

