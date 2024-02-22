extends HBoxContainer

signal JoinGame(ip, port)

func _on_join_pressed():
	JoinGame.emit($ip.text, (int($port.text) - 2) )
