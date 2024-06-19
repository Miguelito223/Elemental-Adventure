extends Node2D

var DEBUGGING = true

var rng = RandomNumberGenerator.new()
@onready var lineedit = $CanvasLayer/LineEdit
@onready var textedit = $CanvasLayer/TextEdit
@onready var tile_map = $TileMap

var player_scene = preload("res://Scenes/player.tscn")

func _ready():
	if DEBUGGING:
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
		}))


		
	Signals.level_loaded.emit()







