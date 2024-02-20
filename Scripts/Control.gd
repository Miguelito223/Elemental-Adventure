extends Node

signal found_server
signal server_removed

var broadcasttimer: Timer

var roominfo = {"name":"name", "playercount": 0}
var broadcaster: PacketPeerUDP
var lisener: PacketPeerUDP

var currentinfo = load("res://Scenes/server_info.tscn")

var lisenerport = 8911
var broadcasterport = 8912
var broadcasteripadress = "192.168.1.255"

func _ready():
	broadcasttimer = $"broadcast timer"

	lisener = PacketPeerUDP.new()

	var ok = lisener.bind(lisenerport)
	if ok == OK:
		print("all correct :D")
	else:
		print("failed D:")

func _process(delta):
	if lisener.get_available_packet_count() > 0:
		var serverip = lisener.get_packet_ip()
		var serverport = lisener.get_packet_port()
		var bytes = lisener.get_packet()
		var data = bytes.get_string_from_ascii()
		var roominfo2 = JSON.parse_string(data)
		
		var child = $Panel/VBoxContainer.find_child(roominfo2.name)
		if child != null:
			child.get_node("ip").text = serverip
			child.get_node("count").text = str(data.playercount)
		else:
			var currentinfo2 = currentinfo.instantiate()
			currentinfo2.get_node("name").text = data.name
			currentinfo2.get_node("ip").text = serverip
			currentinfo2.get_node("port").text = serverport
			currentinfo2.get_node("count").text = str(data.playercount)
			$Panel/VBoxContainer.add_child(currentinfo2)
	
func setupbroadcast(name):
	roominfo.name = name
	roominfo.playercount = Network.connection_count

	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcasteripadress, lisenerport)

	var ok = broadcaster.bind(broadcasterport)
	if ok == OK:
		print("all correct :D")
	else:
		print("failed D:")

	$"broadcast timer".start()

func _on_broadcast_timer_timeout():
	print("broadcaring game!")
	roominfo.playercount = Network.connection_count
	var data = JSON.stringify(roominfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func _exit_tree():
	lisener.close()
	
	$"broadcast timer".stop()
	if broadcaster != null:
		broadcaster.close()
