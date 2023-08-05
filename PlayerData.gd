extends Node

var save_path = "user://PlayerData.json"
var playerdata = {"pos": {"x": -373, "y": -30}, "lifes":3, "coins": 0, "level": "level_1"}

func _ready():
	load_file()

func save_file():
	print("Creating playerdata file")
	var datafile = FileAccess.open(save_path, FileAccess.WRITE)
	datafile.store_line(JSON.stringify(playerdata))

func load_file():
	var datafile = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path):
		print("Playerdata file found")
		playerdata = JSON.parse_string(datafile.get_line())
	else:
		print("Playerdata file doesn't exist!")
		save_file()
	
