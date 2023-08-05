extends Node

var save_path = "user://GameData.json"
var gamedata = {"time": 12, "coins_map": 23}

func _ready():
	load_file()

func save_file():
	print("Creating gamedata json file")
	var datafile = FileAccess.open(save_path, FileAccess.WRITE)
	datafile.store_line(JSON.stringify(gamedata))

func load_file():
	var datafile = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path):
		print("Gamedata file found")
		gamedata = JSON.parse_string(datafile.get_line())
	else:
		print("Gamedata File doesn't exist!")
		save_file()
