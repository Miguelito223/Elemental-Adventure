extends Node

var port = 9999
var ip = "172.0.0.1"
var connection_count = 0
var is_server = false
var is_networking = false
var multiplayer_peer = ENetMultiplayerPeer.new()
var multiplayer_players_numbers = 0