extends Node

var port
var ip
var connection_count = 0
var is_server = false
var is_networking = false
var multiplayer_peer = ENetMultiplayerPeer.new()