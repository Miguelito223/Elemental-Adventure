extends Node

#time
var minute = "00"
var day = "1"
var hour = "12"
var time = 0.0

#others
var num_players = 0
var player_index = 0
var use_keyboard = false
var use_mobile_buttons = true
var player_name = "Fire"

#player
var level = "level_1"
var level_int = 1
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
var resolution = Vector2i(1920, 1080)
var initial_time = "12"
var time_speed = "1.0"
var autosave = true
var autosave_length = "5"
var autosaver_start_time = "0"
var inputs = false
