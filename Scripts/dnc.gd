extends CanvasModulate

var minutes_per_day = 1440
var minutes_per_hour = 60
var ingame_to_real_minute_duration = (2 * PI) / minutes_per_day

@export var gradient:GradientTexture1D
@export var ingame_speed = Globals.time_speed
@export var initial_hour = Globals.initial_time:
	set(h):
		initial_hour = h
		Globals.time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour

var past_minute = -1.0

@rpc("any_peer", "call_local")
func set_time_multiplayer(time):
	Globals.time = time

@rpc("any_peer", "call_local")
func set_day_multiplayer(day):
	Globals.day = day

@rpc("any_peer", "call_local")
func set_hour_multiplayer(hour):
	Globals.hour = hour

@rpc("any_peer", "call_local")
func set_minute_multiplayer(minute):
	Globals.minute = minute

@rpc("any_peer", "call_local")
func set_color_multiplayer(xd):
	self.color = xd

func _ready():
	if Network.is_networking:
		if get_tree().get_multiplayer().is_server():
			Globals.time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour
			set_time_multiplayer.rpc(Globals.time)
			Data.load_file()
	else:
		Globals.time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour
		Data.load_file()

func _process(delta):
	if Network.is_networking:
		if get_tree().get_multiplayer().is_server():
			Globals.time += delta * ingame_to_real_minute_duration * ingame_speed  
			set_time_multiplayer.rpc(Globals.time)
			var value = (sin(Globals.time - PI / 2) + 1.0 / 2.0)
			self.color = gradient.gradient.sample(value)
			set_color_multiplayer.rpc(self.color)
			
			_recalculate_time()


			
		
	else:
		Globals.time += delta * ingame_to_real_minute_duration * ingame_speed  
		var value = (sin(Globals.time - PI / 2) + 1.0 / 2.0)
		self.color = gradient.gradient.sample(value)
		
		_recalculate_time()


func _recalculate_time():
	var total_minutes = int(Globals.time / ingame_to_real_minute_duration)
	Globals.day = int(total_minutes / minutes_per_day)

	var current_day_minutes = total_minutes % minutes_per_day
	Globals.hour = int(current_day_minutes / minutes_per_hour)
	Globals.minute = int(current_day_minutes % minutes_per_hour)

	if past_minute != Globals.minute:
		past_minute = Globals.minute
		set_day_multiplayer.rpc(Globals.day)
		set_hour_multiplayer.rpc(Globals.hour)
		set_minute_multiplayer.rpc(Globals.minute)
		Signals.time_tick.emit(Globals.day, Globals.hour, Globals.minute)
		
