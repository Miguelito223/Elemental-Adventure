extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var bullet = preload("res://lavaball.tscn")
var can_fire = true

@export var max_hearth = 3
@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var Market = $Marker2D
@onready var Pause_Menu = $"CanvasLayer/Pause menu"
@onready var AnimatedSprite = $AnimatedSprite2D

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		DataState.save_file_state()
		
func _ready():
	position.x = Globals.pos_x
	position.y = Globals.pos_y
	setlifes(Globals.hearth)
	Pause_Menu.hide()
	get_tree().paused = false
	
	
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
	
func _input(event):
	
	if event.is_action_pressed("ui_pause_menu"):
		Pause_Menu.show()
		get_tree().paused = true
	if event.is_action_pressed("ui_left"):
		Market.scale.x = -1
	if event.is_action_pressed("ui_right"):
		Market.scale.x = 1
	if event.is_action_pressed("ui_shoot"):
		shot()
		
func shot():
	if can_fire:
		var buller_ins = bullet.instantiate()
		add_child(buller_ins)
		buller_ins.transform = Market.transform
		can_fire = false
		await get_tree().create_timer(0.8).timeout
		can_fire = true

func _physics_process(delta):
	Globals.pos_x = position.x
	Globals.pos_y = position.y
	
	print(Globals.pos_x, Globals.pos_y)

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		AnimatedSprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	up_direction = Vector2(0, -1)

	move_and_slide()
	
func setlifes(value):
	Globals.hearth = clamp(value,0,max_hearth)
	if Globals.hearth <= 0:
		print("you dead")
		Globals.hearth = max_hearth
		Globals.coins = 0
		position.x = -438
		position.y = -41
		DataState.save_file_state()
		LoadScene.load_scene(get_parent(), "res://death_menu.tscn")
		
func getcoin():
	Globals.coins += 1
	DataState.save_file_state()
	
func getlife():
	Globals.hearth += 1
	DataState.save_file_state()
	
func changelevel():
	Globals.level = "level_" + str(int(Globals.level) + 1 ) 
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
	

func _on_exit_pressed():
	Pause_Menu.show()
	get_tree().paused = true


func _on_invunerability_timeout():
	Animation_Effects.play("rest")
	
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"level" : Globals.level,
		"pos_x" :  position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"hearth" : Globals.hearth,
		"coins" : Globals.coins,
		"max_health" : max_hearth,
	}
	return save_dict
	
func load(info):
	name = info.name
	position = Vector2(info.pos_x, info.pos_y)
	scale = Vector2(info.size_x, info.size_y)
