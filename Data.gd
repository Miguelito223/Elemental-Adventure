extends Node

var save_path = "user://Data.json"
var data = {
	"player_data":{
		"pos": {"x": -485, "y": -30}, 
		"lifes":3, 
		"coins": 0, 
		"level": "level_1"
	},
	"settings":{
		"master_volume": 0, 
		"fx_volume": 0, 
		"music_volume": 0, 
		"fullscreen": false, 
		"resolution": "1920x1080", 
		"initial_time": "12", 
		"time_speed": "1.0"
	}
}

func _ready():
	load_file()

func save_file():
	print("Creating data file")
	var datafile = FileAccess.open(save_path, FileAccess.WRITE)
	datafile.store_line(JSON.stringify(data))

func load_file():
	var datafile = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path):
		print("Data file found")
		data = JSON.parse_string(datafile.get_line())
	else:
		print("Data file doesn't exist!")
		save_file()
	
func remove_file():
	DirAccess.remove_absolute(save_path)

func load_volume(bus, value):
	if value >= 45:
		AudioServer.set_bus_mute(bus,true)
	else:
		AudioServer.set_bus_mute(bus,false)
	
	match bus:
		0:
			data.settings.master_volume = value
		1:
			data.settings.music_volume = value
		2:
			data.settings.fx_volume = value
			
	AudioServer.set_bus_volume_db(bus,value)
	
	save_file()
	
func load_fullscreen(value):
	if value == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	data.settings.fullscreen = value
	save_file()
	
func load_resolution(value):
	DisplayServer.window_set_size(value)
	get_viewport().set_size(value)
	data.settings.resolution = value
	save_file()
