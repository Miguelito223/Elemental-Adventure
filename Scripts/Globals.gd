extends Node

#time
var minute = "00"
var day = "1"
var hour = "12"
var time = 0.0

#others
var num_players = 0
var player_index = 0
var player_name = "Fire"

#player

var hud
var level = "level_1"
var level_int = 1
var max_hearth = 3
var hearths = {}
var coins = 0
var score = 0
var pos_x = -438
var pos_y = -41
var size_x = 0.4
var size_y = 0.4

#settings
var master_volume = 0 
var fx_volume = 0
var music_volume = 0
var fullscreen = false
var resolution = Vector2i(1920, 1080) if OS.get_name() == "Windows" or OS.get_name() == "Linux" else Vector2i(2400, 1080)
var initial_time = "12"
var time_speed = "1.0"
var autosave = true
var autosave_length = "5"
var autosaver_start_time = "0"
var use_mobile_buttons = OS.get_name() == "Android"
var use_keyboard = OS.get_name() == "Windows" or OS.get_name() == "Linux"
