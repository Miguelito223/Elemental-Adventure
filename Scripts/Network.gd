extends Node

var port = 9999
var ip = "127.0.0.1"
var username = "MichaxD"
var connection_count = 0
var connected_ids: Array = []
var is_networking = false
var multiplayer_peer_client = ENetMultiplayerPeer.new()
var multiplayer_peer_server = ENetMultiplayerPeer.new()

var player_name: Array = [
	"Fire",
	"Water",
	"Air",
	"Earth",
]
var player_color: Array = [
	"white",
	"blue",
	"gray",
	"green",
]

var ball_color: Array = [
	"orange",
	"blue",
	"gray",
	"green",
]


var alpha = 1.0 # build

var player_color_dict: Dictionary = {
	0: Color(player_color[0], alpha), # color, alpha
	1: Color(player_color[1], alpha), # color, alpha
	2: Color(player_color[2], alpha), # color, alpha
	3: Color(player_color[3], alpha), # color, alpha
}

var ball_color_dict: Dictionary = {
	0: Color(ball_color[0], alpha), # color, alpha
	1: Color(ball_color[1], alpha), # color, alpha
	2: Color(ball_color[2], alpha), # color, alpha
	3: Color(ball_color[3], alpha), # color, alpha
}

#player


var last_position = null
var max_deaths = 5
var max_hearths = 5

var energys: Dictionary = {
	0: 0, 
	1: 0, 
	2: 0, 
	3: 0, 
}
var score: Dictionary = {
	0: 0, 
	1: 0, 
	2: 0, 
	3: 0, 
}
var hearths: Dictionary = {
	0: max_hearths, 
	1: max_hearths, 
	2: max_hearths, 
	3: max_hearths, 
}
var deaths: Dictionary = {
	0: 0, 
	1: 0, 
	2: 0, 
	3: 0, 
}

