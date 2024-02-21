extends Node

signal found_server
signal server_removed
signal JoinGame(ip)

var broadcasttimer: Timer

var roominfo = {"name":"MichaxD", "playercount": 0}
var broadcaster: PacketPeerUDP
var lisener: PacketPeerUDP

var currentinfo = preload("res://Scenes/server_info.tscn")

var lisenerport = 8911
var broadcasterport = Network.port
var broadcasteripadress = "255.255.255.255"

func _ready():
	broadcasttimer = $"broadcast timer"
	setup()


func setup():
	lisener = PacketPeerUDP.new()

	var ok = lisener.bind(lisenerport)
	if ok == OK:
		print("all correct to port: " + str(lisenerport) + " :D")
		$Panel/Label.text = "Bound to lisen port: true"
	else:
		print("failed to port D:")
		$Panel/Label.text = "Bound to lisen port: false"

func _process(_delta):
	if lisener.get_available_packet_count() > 0:
		var serverip = lisener.get_packet_ip()
		var serverport = lisener.get_packet_port()
		var bytes = lisener.get_packet()
		var data = bytes.get_string_from_ascii()
		var roominfo2 = JSON.parse_string(data)

		print(serverip + ":" + str(serverport))
		
		for i in $Panel/VBoxContainer.get_children():
			if i.name == roominfo2.name:
				i.get_node("ip").text = serverip
				i.get_node("port").text = str(serverport)
				i.get_node("count").text = str(roominfo2.playercount)
				return

		var currentinfo2 = currentinfo.instantiate()
		currentinfo2.name = roominfo2.name
		currentinfo2.get_node("Name").text = roominfo2.name
		currentinfo2.get_node("ip").text = serverip
		currentinfo2.get_node("port").text = str(serverport)
		currentinfo2.get_node("count").text = str(roominfo2.playercount)
		currentinfo2.JoinGame.connect(joinbyip)
		$Panel/VBoxContainer.add_child(currentinfo2)
	
func setupbroadcast(player_name):
	roominfo.name = player_name
	roominfo.playercount = Network.connected_ids.size()

	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcasteripadress, lisenerport)

	var ok = broadcaster.bind(broadcasterport)
	if ok == OK:
		print("all correct to port: " + str(broadcasterport) + " :D")
	else:
		print("failed to port D:")
		

	$"broadcast timer".start()

func _on_broadcast_timer_timeout():
	print("broadcaring game!")
	roominfo.playercount = Network.connected_ids.size()
	var data = JSON.stringify(roominfo)
	var packet = data.to_ascii_buffer()
	if broadcaster != null:
		broadcaster.put_packet(packet)

func cleanup():
	lisener.close()
	
	$"broadcast timer".stop()
	if broadcaster != null:
		broadcaster.close()


func _exit_tree():
	cleanup()


func joinbyip(ip):
	JoinGame.emit(ip)
