extends Node

var port = 9999
var ip = "127.0.0.1"
var connection_count = 0
var is_networking = false

@rpc
func send_data_to(data):
	rpc("data_received", data)
