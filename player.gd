extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var bullet = preload("res://lavaball.tscn")
var can_fire = true

@export var max_health = 3
@onready var health = PlayerData.playerdata.lifes
@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var Market = $Marker2D
@onready var Pause_Menu = $"CanvasLayer/Pause menu"
@onready var AnimatedSprite = $AnimatedSprite2D
@onready var coins = PlayerData.playerdata.coins


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		PlayerData.playerdata.pos.x = position.x
		PlayerData.playerdata.pos.y = position.y
		PlayerData.save_file()


func _ready():
	position.y = PlayerData.playerdata.pos.y
	position.x = PlayerData.playerdata.pos.x
	setlifes(PlayerData.playerdata.lifes)
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
		
		
	move_and_slide()
	
func setlifes(value):
	PlayerData.playerdata.lifes = clamp(value,0,max_health)
	if PlayerData.playerdata.lifes <= 0:
		print("you dead")
		PlayerData.playerdata.lifes = max_health
		PlayerData.save_file()
		Global.load_scene(get_parent(), "res://death_menu.tscn")

func damage(ammount):
	if InvunerabilityTime.is_stopped():
		InvunerabilityTime.start()
		setlifes(PlayerData.playerdata.lifes - ammount)
		Animation_Effects.play("damage")
		Animation_Effects.queue("flash")
		PlayerData.save_file()

func update_label():
	$CanvasLayer/Label.text = ": " + str(PlayerData.playerdata.lifes)
	$CanvasLayer/Label2.text = ": " + str(PlayerData.playerdata.coins)
	

func _on_exit_pressed():
	Pause_Menu.show()
	get_tree().paused = true


func _on_invunerability_timeout():
	Animation_Effects.play("rest")
