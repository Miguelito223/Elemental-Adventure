extends Node

var save_path = "user://Data.json"
var data = {}

#player
var player_x = -449
var player_y = -26
var lifes = 3
var coins = 0
var level = "level_1"

#settings
var master_volume = 0 
var fx_volume = 0
var music_volume = 0
var fullscreen = false
var resolution = "1920x1080"
var initial_time = "12"
var time_speed = "1.0"
var autosave = false
var autosave_length = 5
var autosaver_start_time = 0

func save_file():
	print("Creating data file")
	data = {
		"player_data":{
			"pos": {"x": player_x, "y": player_y}, 
			"lifes": lifes , 
			"coins": coins, 
			"level": level
		},
		"settings":{
			"master_volume": master_volume, 
			"fx_volume": fx_volume, 
			"music_volume": music_volume, 
			"fullscreen": fullscreen, 
			"resolution": resolution, 
			"initial_time": initial_time, 
			"time_speed": time_speed,
			"autosave": autosave,
			"autosave_length": autosave_length,
			"autosaver_start_time": autosaver_start_time
		}
	}
	var datafile = FileAccess.open(save_path, FileAccess.WRITE)
	datafile.store_line(JSON.stringify(data))

func load_file():
	var datafile = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path):
		print("Data file found")
		data = JSON.parse_string(datafile.get_as_text())
		
		var settings = data["settings"]
		var player_data = data["player_data"]
		
		#settings
		master_volume = settings["master_volume"]
		fx_volume = settings["fx_volume"]
		music_volume = settings["music_volume"]
		fullscreen = settings["fullscreen"]
		resolution = settings["resolution"]
		initial_time = settings["initial_time"]
		time_speed = settings["time_speed"]
		autosave = settings["autosave"]
		autosave_length = settings["autosave_length"]
		autosaver_start_time = settings["autosaver_start_time"]
		
		#player
		player_x = player_data.pos.x
		player_y = player_data.pos.y
		lifes = player_data["lifes"]
		coins = player_data["coins"]
		level = player_data["level"]
	else:
		print("Data file doesn't exist!")
		save_file()
	
func _ready():
	load_file()
	
func remove_file():
	DirAccess.remove_absolute(save_path)

func load_volume(bus, value):
	if value >= 45:
		AudioServer.set_bus_mute(bus,true)
	else:
		AudioServer.set_bus_mute(bus,false)
	
	match bus:
		0:
			master_volume = value
		1:
			music_volume = value
		2:
			fx_volume = value
			
	AudioServer.set_bus_volume_db(bus,value)
	
	save_file()
	
func load_fullscreen(value):
	if value == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen = value
	save_file()
	
func load_resolution(value):
	DisplayServer.window_set_size(value)
	get_viewport().set_size(value)
	resolution = value
	save_file()
	
func _physics_process(delta):
	if autosave:
		autosave_logic()
	
func autosave_logic():
	var time_passed = Time.get_unix_time_from_system() - autosaver_start_time
		
	if time_passed > (autosave_length * 60):
		save_file()
		autosaver_start_time = Time.get_unix_time_from_system()
