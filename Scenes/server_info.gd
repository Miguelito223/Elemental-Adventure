extends HBoxContainer

signal JoinGame(ip)

func _on_join_pressed():
	JoinGame.emit($ip.text)
