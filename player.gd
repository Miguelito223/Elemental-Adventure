extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var bullet = preload("res://lavaball.tscn")
var can_fire = true

@export var max_health = 3
@onready var health = Data.data.player_data.lifes
@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var Market = $Marker2D
@onready var Pause_Menu = $"CanvasLayer/Pause menu"
@onready var AnimatedSprite = $AnimatedSprite2D
@onready var coins = Data.data.player_data.coins

func _ready():
	position.y = Data.player_y
	position.x = Data.player_x
	setlifes(Data.lifes)
	Pause_Menu.hide()
	get_tree().paused = false
	
func _process(_delta):
	if velocity.x > 0 or velocity.x < 0:
		AnimatedSprite.play("walk")
	elif velocity.y < 0:
		AnimatedSprite.play("jump")
	elif velocity.y > 0:
		AnimatedSprite.play("fall")
	else:
		AnimatedSprite.play("idle")
		
	update_label()
	
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
	Data.player_x = position.x
	Data.player_y = position.y
	
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
	floor_stop_on_slope = true
	floor_constant_speed = true

	move_and_slide()
	
func setlifes(value):
	Data.lifes = clamp(value,0,max_health)
	if Data.lifes <= 0:
		print("you dead")
		Data.lifes = max_health
		Data.player_x = -449
		Data.player_y = -26
		Data.save_file()
		LoadScene.load_scene(get_parent(), "res://death_menu.tscn")

func damage(ammount):
	if InvunerabilityTime.is_stopped():
		InvunerabilityTime.start()
		setlifes(Data.lifes - ammount)
		Animation_Effects.play("damage")
		Animation_Effects.queue("flash")
		Data.save_file()

func update_label():
	$CanvasLayer/Label.text = ": " + str(Data.lifes)
	$CanvasLayer/Label2.text = ": " + str(Data.coins)
	

func _on_exit_pressed():
	Pause_Menu.show()
	get_tree().paused = true


func _on_invunerability_timeout():
	Animation_Effects.play("rest")
