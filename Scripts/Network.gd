extends Node

var port = 9999
var ip = "127.0.0.1"
var connection_count = 0
var is_networking = false

func send_data_to(id, data):
    rpc_id(id, "data_received", data)
