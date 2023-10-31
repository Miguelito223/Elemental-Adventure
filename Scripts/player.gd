extends CharacterBody2D

var DEBUGGING
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var bullet = preload("res://Scenes/lavaball.tscn")
var can_fire = true

@export var max_hearth = 3
@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var Market = $Marker2D
@onready var Pause_Menu = $"CanvasLayer/Pause menu"
@onready var AnimatedSprite = $AnimatedSprite2D

var max_speed = 300
var max_speed_in_water = 200
var jump_speed = -400.0
var speed = 1500
var friction = 1200
var axis = Vector2.ZERO

var color: Color = Color("White", 1) # color, alpha

var player_name: String = "player_name"
var device_num: int = 0 # default to device 0
var is_moving: bool = false

func _on_disconnected(name):
	if player_name == name:
		print("disconnected player: '%s'" % name)
		modulate.a = 0.3

func _on_connected(name):
	if player_name == name:
		print("connected player: '%s'" % name)
		modulate.a = 1.0
		

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		DataState.save_file_state()
		
func _ready():
	var parent_node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING
	else:
		DEBUGGING = true

	Signals.connected.connect(_on_connected)
	Signals.disconnected.connect(_on_disconnected) 

	if DEBUGGING:
		print("Running Player.gd: {n}._ready()... {pn}".format({
			"n": name,
			"pn": player_name,
			}))
		# Report scene hierarchy.
		print("Parent of '{n}' is '{p}'".format({
			"n":name,
			"p":get_parent().name,
			}))
			
	AnimatedSprite.modulate = color
	
	position.x = -450
	position.y = -57
	setlifes(Globals.hearth)
	Pause_Menu.hide()
	get_tree().paused = false

	DataState.load_file_state()	
	Signals.player_ready.emit()


	
	
func _process(_delta):	
	update_label()

	if velocity.x > 0 or velocity.x < 0:
		AnimatedSprite.play("walk")
	elif velocity.y < 0:
		AnimatedSprite.play("jump")
	elif velocity.y > 0:
		AnimatedSprite.play("fall")
	else:
		AnimatedSprite.play("idle")
		
	
var ui_inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left":  Vector2.LEFT,
	"ui_jump": null,
	"ui_shoot": null,
	"ui_pause": null,
}

func _physics_process(delta):
	
	Globals.pos_x = position.x
	Globals.pos_y = position.y

	move(delta)

func get_input_axis():
	axis.x = int(Input.is_action_pressed(ui_inputs.keys()[0])) - int(Input.is_action_pressed(ui_inputs.keys()[1]))
	return axis.normalized()
	
func move(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	axis = get_input_axis()

	if axis == Vector2.ZERO:
		apply_fricction(friction * delta)
		$Pasos.stop()
	else:
		apply_movement(axis * speed * delta)
		$Pasos.stop()

	if Input.is_action_pressed(ui_inputs.keys()[2]) and is_on_floor():
		velocity.y = jump_speed
		
	AnimatedSprite.flip_h = axis < Vector2.ZERO

	move_and_slide()

func apply_fricction(amount):
	if velocity.length() > amount:
		velocity.x -= velocity.normalized().x * amount
	else:
		velocity.x = 0

func apply_movement(accel):
	velocity.x += accel.x
	if velocity.x > max_speed:
		velocity.x = max_speed



func _input(event):
	
	if event.is_action_pressed(ui_inputs.keys()[4]):
		Pause_Menu.show()
		get_tree().paused = true
	if event.is_action_pressed(ui_inputs.keys()[1]):
		Market.scale.x = -1
	if event.is_action_pressed(ui_inputs.keys()[0]):
		Market.scale.x = 1
	if event.is_action_pressed(ui_inputs.keys()[3]):
		shot()
		
func shot():
	if can_fire:
		var buller_ins = bullet.instantiate()
		add_child(buller_ins)
		buller_ins.transform = Market.transform
		can_fire = false
		await get_tree().create_timer(0.8).timeout
		can_fire = true
	
func setlifes(value):
	Globals.hearth = clamp(value,0,max_hearth)
	if Globals.hearth <= 0:
		print("you dead")
		Globals.hearth = max_hearth
		position.x = -438
		position.y = -41
		DataState.save_file_state()
		LoadScene.load_scene(self, "res://Scenes/death_menu.tscn")
		
func getcoin():
	Globals.coins += 1
	DataState.save_file_state()
	
func getlife():
	Globals.hearth += 1
	DataState.save_file_state()
	
func changelevel():
	Globals.level = "level_" + str(int(Globals.level) + 1 ) 
	save().parent = "/root/" + Globals.level
	DataState.save_file_state()
	
func setposspawn():
	set_position(Vector2(-449, -26))
	DataState.save_file_state()

func damage(ammount):
	if InvunerabilityTime.is_stopped():
		InvunerabilityTime.start()
		setlifes(Globals.hearth - ammount)
		Animation_Effects.play("damage")
		Animation_Effects.queue("flash")
		DataState.save_file_state()
		

func update_label():
	$CanvasLayer/Label.text = ": " + str(Globals.hearth)
	$CanvasLayer/Label2.text = ": " + str(Globals.coins)
	$CanvasLayer/Label3.text = str(Globals.hour)  + ":" + str(Globals.minute)
	

func _on_exit_pressed():
	Pause_Menu.show()
	get_tree().paused = true
	
func in_water():
	damage(3)
	gravity = gravity / 3
	max_speed = max_speed_in_water


func _on_invunerability_timeout():
	Animation_Effects.play("rest")
	
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : player_name,
		"level" : Globals.level,
		"pos_x" :  position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"color" : color,
		"hearth" : Globals.hearth,
		"coins" : Globals.coins,
		"max_health" : max_hearth,
	}
	return save_dict
	
func load(info):
	Globals.level = info.level
	Globals.hearth = info.hearth
	Globals.coins = info.coins
	Globals.pos_y = info.pos_y
	Globals.pos_x = info.pos_x
	Globals.size_y = info.size_y
	Globals.size_x = info.size_x
	name = info.name
	player_name = info.name
	position = Vector2(info.pos_x,info.pos_y)
	scale = Vector2(info.size_x, info.size_y)
	modulate = str_to_var("Color" + info.color)
