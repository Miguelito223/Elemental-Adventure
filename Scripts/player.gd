extends CharacterBody2D

var DEBUGGING
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var gravity_swim = 0.25
var velocity_swim = 80.0

var is_in_water = false
var is_in_lava = false

var bullet = preload("res://Scenes/fireball.tscn")
var bullet_lol
var can_fire = true

@onready var InvunerabilityTime = $Invunerability
@onready var Animation_Effects = $AnimationPlayer
@onready var Marker = $Node2D/Marker2D
@onready var Marker_Parent = $Node2D
@onready var Pause_Menu = $"Pause menu"
@onready var AnimatedSprite = $AnimatedSprite2D
@onready var light = $PointLight2D
@onready var Hud = $Hud
@onready var MobileButtons = $Mobilecontrolls
@onready var syncronizer = $MultiplayerSynchronizer
var max_speed = 300.0
var max_speed_in_air = 500.0
var max_speed_in_water = 200.0
var max_speed_in_lava = 100.0
var jump_speed = -400.0
var jump_speed_swim = -25
var speed = 500.0
var friction = 1200.0
var axis = Vector2.ZERO

var device_num = 0 # default to device 0
var player_id = 1

var Max_Hearths = Globals.max_hearths
var player_name = "Fire"
var deaths = 0
var Hearths = Max_Hearths
var energys = 0
var score = 0

var player_color = Color("White", 1) # color, alpha
var ball_color = Color("White", 1) # color, alpha

var last_position = null
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


	Globals.player[device_num] = self
	Pause_Menu.hide()
	get_tree().paused = false
	setlifes(Hearths)

	if Network.is_networking:
		if syncronizer.is_multiplayer_authority():
			Max_Hearths = Network.max_hearths
			last_position = Network.last_position
			player_name = Network.username
			Hearths = Network.hearths[device_num]
			deaths = Network.deaths[device_num]
			player_color = Network.player_color_dict[device_num]
			ball_color = Network.ball_color_dict[device_num]  
			energys = Network.energys[device_num]
			score = Network.score[device_num]
	else:
		Max_Hearths = Globals.max_hearths
		last_position = Globals.last_position
		name = Globals.player_name[device_num]
		ball_color = Globals.ball_color_dict[device_num]
		player_color = Globals.player_color_dict[device_num]
		player_name = Globals.player_name[device_num]  
		Hearths = Globals.hearths[device_num]
		deaths = Globals.deaths[device_num]
		energys = Globals.energys[device_num]
		score = Globals.score[device_num]	

	


	Signals.player_ready.emit()



func _enter_tree():
	if Network.is_networking:
		set_multiplayer_authority(str(name).to_int())
		setposspawn()

func _input(event):
	if Network.is_networking:
		if syncronizer.is_multiplayer_authority():
			if event.is_action_pressed(ui_inputs.keys()[5]):
				position.y += 1
			
			if event.is_action_pressed(ui_inputs.keys()[3]) and can_fire:
				shoot.rpc(Marker_Parent.rotation, Marker.global_position, 500)

			if event is InputEventScreenTouch and can_fire:
				shoot.rpc(Marker_Parent.rotation, Marker.global_position, 500)
	else:
		if event.is_action_pressed(ui_inputs.keys()[5]):
			position.y += 1
		
		if event.is_action_pressed(ui_inputs.keys()[3]) and can_fire:
			shoot(Marker_Parent.rotation, Marker.global_position, 500)

		if event is InputEventScreenTouch and can_fire:
			shoot(Marker_Parent.rotation, Marker.global_position, 500)


	
func _process(_delta):	
	if Network.is_networking:
		if syncronizer.is_multiplayer_authority():
			if velocity.x < 0:
				AnimatedSprite.scale.x = -1
			else:
				AnimatedSprite.scale.x = 1

			if Globals.use_keyboard:
				Marker_Parent.look_at(get_global_mouse_position())
			else:
				Marker_Parent.scale.x = AnimatedSprite.scale.x
	else:
		if velocity.x < 0:
			AnimatedSprite.scale.x = -1
		else:
			AnimatedSprite.scale.x = 1

		if Globals.use_keyboard:
			Marker_Parent.look_at(get_global_mouse_position())
		else:
			Marker_Parent.scale.x = AnimatedSprite.scale.x
		
	$Name.text = str(player_name)

	if not Network.is_networking:
		Globals.max_hearths = Max_Hearths
		Globals.last_position = last_position
		Globals.player_name[device_num] = player_name
		Globals.hearths[device_num] = Hearths
		Globals.deaths[device_num] = deaths
		Globals.energys[device_num] = energys
		Globals.score[device_num] = score
	else:
		if syncronizer.is_multiplayer_authority():
			Network.max_hearths = Max_Hearths
			Network.last_position = last_position
			Network.player_name[device_num] = player_name
			Network.hearths[device_num] = Hearths
			Network.deaths[device_num] = deaths
			Network.energys[device_num] = energys
			Network.score[device_num] = score
	
	if Network.is_networking:
		if syncronizer.is_multiplayer_authority():
			Hud.show()
		else:
			Hud.hide()

	if device_num == 0:
		if not Network.is_networking:
			Hud.show()
		light.enabled = Globals.Graphics
		light.shadow_enabled = Globals.Graphics
		light.shadow_filter_smooth = 4 - Globals.Graphics

		if Globals.Graphics == 0:
			light.shadow_filter = 0
		elif Globals.Graphics == 2:
			light.shadow_filter = 1
		elif Globals.Graphics == 3:
			light.shadow_filter = 2
		else:
			if Globals.Graphics > 3 :
				light.shadow_filter = 2
			elif Globals.Graphics < 0:
				light.shadow_filter = 0
			else:
				light.shadow_filter = 1

		
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("fire walk")
		elif velocity.y < 0:
			AnimatedSprite.play("fire jump")
		elif velocity.y > 0:
			AnimatedSprite.play("fire fall")
		else:
			AnimatedSprite.play("fire idle")
	elif device_num == 1:
		if not Network.is_networking:
			Hud.hide()
		light.enabled = false
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("water walk")
		elif velocity.y < 0:
			AnimatedSprite.play("water jump")
		elif velocity.y > 0:
			AnimatedSprite.play("water fall")
		else:
			AnimatedSprite.play("water idle")
	elif device_num == 2:
		if not Network.is_networking:
			Hud.hide()
		light.enabled = false
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("air walk")
		elif velocity.y < 0:
			AnimatedSprite.play("air jump")
		elif velocity.y > 0:
			AnimatedSprite.play("air fall")
		else:
			AnimatedSprite.play("air idle")
	elif device_num == 3:
		if not Network.is_networking:
			Hud.hide()
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
		if not Network.is_networking:
			Hud.hide()
		light.enabled = true
		modulate = str_to_var("Color" + str(player_color))
		if velocity.x > 0 or velocity.x < 0:
			AnimatedSprite.play("fire walk")
		elif velocity.y < 0:
			AnimatedSprite.play("fire jump")
		elif velocity.y > 0:
			AnimatedSprite.play("fire fall")
		else:
			AnimatedSprite.play("fire idle")		

		
	
var ui_inputs = {

	"right{n}".format({"n":device_num}): Vector2.RIGHT,
	"left{n}".format({"n":device_num}): Vector2.LEFT,
	"jump{n}".format({"n":device_num}): null,
	"shoot{n}".format({"n":device_num}): null,
	"pause{n}".format({"n":device_num}): null,
	"down{n}".format({"n":device_num}): null,
		
}


func get_input_axis():
	axis.x = int(Input.is_action_pressed(ui_inputs.keys()[0])) - int(Input.is_action_pressed(ui_inputs.keys()[1]))
	return axis.normalized()

func _physics_process(delta):
	if Network.is_networking:
		if syncronizer.is_multiplayer_authority():
			move(delta, axis * speed * delta, friction * delta)
	else:
		move(delta, axis * speed * delta, friction * delta)

	move_and_slide()


func move(delta, accel, amount):
	
	if not is_on_floor():
		if (!is_in_water or !is_in_lava):
			velocity.y += gravity * delta 
		else:
			velocity.y = clampf(velocity.y + (gravity * delta * gravity_swim), -10000, velocity_swim)

	axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		if velocity.length() > amount:
			velocity.x -= velocity.normalized().x * amount
		else:
			velocity.x = 0

		is_moving = false

		if $Pasos.playing:
			$Pasos.stop()
	else:
		velocity.x += accel.x
		if is_on_floor():
			velocity.x = velocity.limit_length(max_speed).x
		else:
			velocity.x = velocity.limit_length(max_speed_in_air).x

		
		is_moving = true
		if is_on_floor():
			if !$Pasos.playing:
				$Pasos.play()	
		else:
			if $Pasos.playing:
				$Pasos.stop()	


	if Input.is_action_pressed(ui_inputs.keys()[2]):
		if is_on_floor():
			velocity.y = jump_speed
		
		if is_in_water == true or is_in_lava == true:
			velocity.y += jump_speed_swim

@rpc("any_peer", "call_local")
func shoot( bullet_direction, bullet_pos, bullet_speed):
	bullet_lol = bullet.instantiate()
	var fire = bullet_lol.get_node("Fire")
	var PointLight = bullet_lol.get_node("PointLight2D")
	get_parent().add_child(bullet_lol, true)

	bullet_lol.set_rotation(bullet_direction)
	bullet_lol.set_global_position(bullet_pos)
	bullet_lol.modulate = str_to_var("Color" + str(ball_color))
	
	if device_num == 0:
		fire.emitting = true
		PointLight.enabled = Globals.Graphics
		PointLight.shadow_enabled = Globals.Graphics

		if Globals.Graphics == 0:
			PointLight.shadow_filter = 0
		elif Globals.Graphics == 2:
			PointLight.shadow_filter = 1
		elif Globals.Graphics == 3:
			PointLight.shadow_filter = 2
		else:
			if Globals.Graphics > 3 :
				PointLight.shadow_filter = 2
			elif Globals.Graphics < 0:
				PointLight.shadow_filter = 0
			else:
				PointLight.shadow_filter = 1
	else:
		fire.emitting = false
		PointLight.enabled = false
		PointLight.shadow_enabled = Globals.Graphics

		if Globals.Graphics == 0:
			PointLight.shadow_filter = 0
		elif Globals.Graphics == 2:
			PointLight.shadow_filter = 1
		elif Globals.Graphics == 3:
			PointLight.shadow_filter = 2
		else:
			if Globals.Graphics > 3 :
				PointLight.shadow_filter = 2
			elif Globals.Graphics < 0:
				PointLight.shadow_filter = 0
			else:
				PointLight.shadow_filter = 1

	bullet_lol.velocity = Vector2(bullet_speed * Marker_Parent.scale.x, 0).rotated(bullet_direction)
	can_fire = false
	await get_tree().create_timer(0.5).timeout
	can_fire = true


func setlifes(value):
	Hearths = clamp(value,0,Max_Hearths)
	if Hearths <= 0:
		if Network.is_networking:
			if syncronizer.is_multiplayer_authority():
				print("you dead")
				Hearths = Max_Hearths
				deaths += 1
				setposspawn()
				if deaths == 1:
					print("you dead, game over")
					deaths = 0
					setposspawn()
					LoadScene.load_scene(null, "res://Scenes/game_over_menu.tscn")
		else:
			if device_num == 0:
				print("you dead")
				Hearths = Max_Hearths
				deaths += 1
				setposspawn()
				if deaths >= Max_Hearths:
					print("you dead, game over")
					deaths = 0
					setposspawn()
					LoadScene.load_scene(get_parent(), "res://Scenes/game_over_menu.tscn")
			else:
				print("player number: '%s'" % device_num)
				Hearths = Max_Hearths
				setposspawn()


	
func getenergy():
	energys += 1
	score += 3
	DataState.save_file_state()
	Data.save_file()
	

func getlife():
	Hearths += 1
	DataState.save_file_state()
	Data.save_file()
	

func changelevel():
	Globals.level_int += 1
	Globals.level = "level_" + str(Globals.level_int)
	save_state().parent = "/root/Game/" + Globals.level
	DataState.save_file_state()
	Data.save_file()
	
func setposspawn():
	if last_position:
		position = last_position
	else:
		if device_num == 0:
			last_position = Vector2(-460,-45)
			position = last_position
			last_position = null
		elif device_num == 1:
			last_position = Vector2(-399,-45)
			position = last_position
			last_position = null
		elif device_num == 2:
			last_position = Vector2(-340,-45)
			position = last_position
			last_position = null
		elif device_num == 3:
			last_position = Vector2(-280,-45)
			position = last_position
			last_position = null
		else:
			print("no more of four players")
			return	

@rpc("any_peer", "call_local")
func damage(ammount):
	if Network.is_networking:
		if InvunerabilityTime.is_stopped() or is_in_water or is_in_lava:
			InvunerabilityTime.start()
			setlifes(Hearths - ammount)
			Animation_Effects.play("damage")
			Animation_Effects.queue("flash")
			score -= 3
			if score < 0:
				score = 0
			DataState.save_file_state()
			Data.save_file()
	else:
		if InvunerabilityTime.is_stopped() or is_in_water or is_in_lava:
			InvunerabilityTime.start()
			setlifes(Hearths - ammount)
			Animation_Effects.play("damage")
			Animation_Effects.queue("flash")
			score -= 3
			if score < 0:
				score = 0
			DataState.save_file_state()
			Data.save_file()

		
	

func _on_exit_pressed():
	Pause_Menu.show()
	get_tree().paused = true
	
func in_water():
	if is_in_water == false:
		if $WaterDetector2D.get_overlapping_bodies().size() >= 1:
			is_in_water = true
			print(is_in_water)

			if not device_num == 1:
				if Network.is_networking:
					damage.rpc(Max_Hearths)
				else:
					damage(Max_Hearths)

func out_water():
	if $WaterDetector2D.get_overlapping_bodies().size() == 0:
		is_in_water = false
		print(is_in_water)



func in_lava():
	if $LavaDetector2D.get_overlapping_bodies().size() >= 1:
		is_in_lava = true
		print(is_in_lava)

		if not device_num == 0:
			if Network.is_networking:
				damage.rpc(Max_Hearths)
			else:
				damage(Max_Hearths)

func out_lava():
	if $LavaDetector2D.get_overlapping_bodies().size() == 0:
		is_in_lava = false
		print(is_in_lava)




func _on_water_detector_2d_body_entered(_body):
	in_water()

func _on_water_detector_2d_body_exited(_body):
	out_water()

func _on_lava_detector_2d_body_entered(_body):
	in_lava()

func _on_lava_detector_2d_body_exited(_body):
	out_lava()



func _on_invunerability_timeout():
	Animation_Effects.play("rest")

func _on_animation_player_animation_finished(_anim_name):
	pass

func save_state():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"player_name" : player_name,
		"pos_x" :  position.x,
		"pos_y" : position.y,
		"size_x" : scale.x,
		"size_y" : scale.y,
		"player_color" : player_color,
		"ball_color" : ball_color,
		"Hearths" : Hearths,
		"energys" : energys,
		"device_num": device_num,
		"score" : score,
		"Deaths" : deaths,
	}
	
func load_state(info):
	energys = info.energys
	score = info.score
	Hearths = info.Hearths
	deaths = info.Deaths
	scale = Vector2(info.size_x, info.size_y)
	position = Vector2(info.pos_x,info.pos_y)
