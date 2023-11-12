extends CharacterBody2D

var DEBUGGING
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var gravity_swim = 0.25
var velocity_swim = 200
var jump_speed_swim = -100
var is_in_water = false
var is_in_lava = false

var bullet = preload("res://Scenes/fireball.tscn")
var can_fire = true

@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var Marker = $Node2D/Marker2D
@onready var Marker_Parent = $Node2D
@onready var Pause_Menu = $"CanvasLayer/Pause menu"
@onready var AnimatedSprite = $AnimatedSprite2D
@onready var light = $PointLight2D

var max_speed = 300
var max_speed_in_air = 500
var max_speed_in_water = 200
var max_speed_in_lava = 100
var jump_speed = -400.0
var speed = 1500
var friction = 1200
var axis = Vector2.ZERO

var player_name = "Fire"

var start_position = Vector2(100.0, 100.0)

var color = Color("White", 1) # color, alpha

var device_num: int = 0 # default to device 0
var is_moving: bool = false
		
func _ready():
	var parent_node = get_parent()
	if parent_node.name != "root":
		DEBUGGING = parent_node.DEBUGGING
	else:
		DEBUGGING = true

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
	
	Pause_Menu.hide()
	position = start_position

	get_tree().paused = false
	setlifes(Globals.hearths[str(Globals.player_index)])
	Signals.player_ready.emit()

	
func _process(_delta):	
	if Globals.use_keyboard:
		Marker_Parent.look_at(get_global_mouse_position())
	else:
		if velocity.x < 0:
			Marker_Parent.scale.x = -1
		elif velocity.x > 0:
			Marker_Parent.scale.x = 1

	if velocity.x < 0:
		AnimatedSprite.scale.x = -1
	elif velocity.x > 0:
		AnimatedSprite.scale.x = 1
		

	if player_name == "Fire":
		light.enabled = true
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("fire walk")
		elif velocity.y < 0:
			AnimatedSprite.play("fire jump")
		elif velocity.y > 0:
			AnimatedSprite.play("fire fall")
		else:
			AnimatedSprite.play("fire idle")
	if player_name == "Water":
		light.enabled = false
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("water walk")
		elif velocity.y < 0:
			AnimatedSprite.play("water jump")
		elif velocity.y > 0:
			AnimatedSprite.play("water fall")
		else:
			AnimatedSprite.play("water idle")
	elif player_name == "Air":
		light.enabled = false
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("air walk")
		elif velocity.y < 0:
			AnimatedSprite.play("air jump")
		elif velocity.y > 0:
			AnimatedSprite.play("air fall")
		else:
			AnimatedSprite.play("air idle")
	elif player_name == "Earth":
		light.enabled = false
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("earth walk")
		elif velocity.y < 0:
			AnimatedSprite.play("earth jump")
		elif velocity.y > 0:
			AnimatedSprite.play("earth fall")
		else:
			AnimatedSprite.play("earth idle")
	else:
		light.enabled = true
		modulate = str_to_var("Color" + str(color))
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("fire walk")
		elif velocity.y < 0:
			AnimatedSprite.play("fire jump")
		elif velocity.y > 0:
			AnimatedSprite.play("fire fall")
		else:
			AnimatedSprite.play("fire idle")		

		
	
var ui_inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left":  Vector2.LEFT,
	"ui_jump": null,
	"ui_shoot": null,
	"ui_pause": null,
	"ui_down": null,
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
		if not is_in_water or not is_in_lava:
			velocity.y += gravity * delta 
		else:
			velocity.y = clamp( velocity.y + (gravity * delta * gravity_swim), -velocity_swim, velocity_swim)
		
	axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_fricction(friction * delta)
		is_moving = false
		if $Pasos.playing:
			$Pasos.stop()
	else:
		apply_movement(axis * speed * delta)
		is_moving = true
		if is_on_floor():
			if !$Pasos.playing:
				$Pasos.play()	

	if Input.is_action_pressed(ui_inputs.keys()[2]):
		if is_on_floor():
			velocity.y = jump_speed
		
		if is_in_water == true or is_in_lava == true:
			velocity.y += jump_speed_swim

	move_and_slide()

func apply_fricction(amount):
	if velocity.length() > amount:
		velocity.x -= velocity.normalized().x * amount
	else:
		velocity.x = 0

func apply_movement(accel):
	velocity.x += accel.x
	if is_on_floor():
		velocity.x = velocity.limit_length(max_speed).x
	else:
		velocity.x = velocity.limit_length(max_speed_in_air).x



func _input(event):
	
	if event.is_action_pressed(ui_inputs.keys()[4]):
		Pause_Menu.show()
		get_tree().paused = true
	if event.is_action_pressed(ui_inputs.keys()[5]):
		position.y += 1
	if event.is_action_pressed(ui_inputs.keys()[3]):
		shoot(Marker_Parent.get_rotation(), Marker.get_global_position(), 500)
		
func shoot( bullet_direction, bullet_pos, bullet_speed):
	if can_fire:
		var bullet_lol = bullet.instantiate()
		var fire = bullet_lol.get_node("Fire")
		var PointLight = bullet_lol.get_node("PointLight2D")
		get_parent().add_child(bullet_lol)

		bullet_lol.set_rotation(bullet_direction)
		bullet_lol.set_global_position(bullet_pos)
		bullet_lol.modulate = str_to_var("Color" + str(color))
		
		if player_name == "Fire":
			fire.emitting = true
			PointLight.enabled = true
		else:
			fire.emitting = false
			PointLight.enabled = false

		if not Globals.use_keyboard or Globals.use_mobile_buttons :
			if Marker_Parent.scale.x == 1:
				bullet_lol.velocity = Vector2(bullet_speed, 0)
			elif Marker_Parent.scale.x == -1 :
				bullet_lol.velocity = Vector2(-bullet_speed, 0)
		else:
			bullet_lol.velocity = Vector2(bullet_speed, 0).rotated(bullet_direction)	


		



		can_fire = false
		await get_tree().create_timer(0.8).timeout
		can_fire = true

	
func setlifes(value):
	Globals.hearths[str(Globals.player_index)] = clamp(value,0,Globals.max_hearth)
	if Globals.hearths[str(Globals.player_index)] <= 0:
		if player_name == "Fire":
			print("you dead")
			Globals.hearths[str(Globals.player_index)] = Globals.max_hearth
			position = start_position
			DataState.save_file_state()
			Data.save_file()
			LoadScene.load_scene(get_parent(), "res://Scenes/game_over_menu.tscn")
		else:
			print("player number: '%s'" % device_num)
			Globals.hearths[str(Globals.player_index)] = Globals.max_hearth
			position = start_position
			DataState.save_file_state()
			Data.save_file()
		
func getcoin():
	Globals.coins += 1
	Globals.score += 3
	Globals.hud.update_label()
	DataState.save_file_state()
	Data.save_file()
	
func getlife():
	Globals.hearths[str(Globals.player_index)] += 1
	Globals.hud.update_label()
	DataState.save_file_state()
	Data.save_file()
	
func changelevel():
	Globals.level = "level_" + str(int(Globals.level) + 1 ) 
	save().parent = "/root/" + Globals.level
	DataState.save_file_state()
	Data.save_file()
	
func setposspawn():
	set_position(Vector2(-449, -26))
	DataState.save_file_state()
	Data.save_file()

func damage(ammount):
	if InvunerabilityTime.is_stopped():
		InvunerabilityTime.start()
		setlifes(Globals.hearths[str(Globals.player_index)] - ammount)
		Animation_Effects.play("damage")
		Animation_Effects.queue("flash")
		Globals.score -= 3
		if Globals.score < 0:
			Globals.score = 0
		Globals.hud.update_label()
		DataState.save_file_state()
		Data.save_file()
		
	

func _on_exit_pressed():
	Pause_Menu.show()
	get_tree().paused = true
	
func in_water():
	if is_in_water == false:
		is_in_water = true
		print(is_in_water)

		if not player_name == "Water":
			damage(3)

		gravity = gravity / 3
		max_speed = max_speed_in_water

func out_water():
	if is_in_water == true:
		is_in_water = false
		print(is_in_water)

		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		max_speed = 300

func out_lava():
	is_in_water = false
	print(is_in_water)

	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	max_speed = 300

func in_lava():
	is_in_water = true
	print(is_in_water)

	if not player_name == "Fire":
		damage(3)

	gravity = gravity / 3
	max_speed = max_speed_in_lava



func _on_water_detector_2d_body_entered(body):
	in_water()

func _on_water_detector_2d_body_exited(body):
	out_water()

func _on_lava_detector_2d_body_entered(body):
	in_lava()

func _on_lava_detector_2d_body_exited(body):
	out_lava()



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
		"hearths" : Globals.hearths,
		"coins" : Globals.coins,
		"score" : Globals.score,
		"max_healths" : Globals.max_hearth,
	}
	return save_dict
	
func load(info):
	Globals.level = info.level
	Globals.hearths = info.hearths
	Globals.name = info.name
	Globals.coins = info.coins
	Globals.score = info.score
	Globals.pos_y = info.pos_y
	Globals.pos_x = info.pos_x
	Globals.size_y = info.size_y
	Globals.size_x = info.size_x
	position = Vector2(info.pos_x,info.pos_y)
	scale = Vector2(info.size_x, info.size_y)
	print(info.color)


func _on_animation_player_animation_finished(anim_name):
	pass

