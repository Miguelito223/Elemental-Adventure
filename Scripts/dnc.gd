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
func _recalculate_time():
	var total_minutes = int(Globals.time / ingame_to_real_minute_duration)
	Globals.day = int(total_minutes / minutes_per_day)

	var current_day_minutes = total_minutes % minutes_per_day
	Globals.hour = int(current_day_minutes / minutes_per_hour)
	Globals.minute = int(current_day_minutes % minutes_per_hour)

	if past_minute != Globals.minute:
		past_minute = Globals.minute
		Signals.time_tick.emit(Globals.day, Globals.hour, Globals.minute)

func _ready():
	if Network.is_networking:
		if get_tree().get_multiplayer().is_server():
			Globals.time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour
			set_time_multiplayer.rpc(Globals.time)
			_recalculate_time.rpc()
	else:
		Globals.time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour
		Data.load_file()

func _process(delta):
	if Network.is_networking:
		if get_tree().get_multiplayer().is_server():
			Globals.time += delta * ingame_to_real_minute_duration * ingame_speed  
			set_time_multiplayer.rpc(Globals.time)
			_recalculate_time.rpc()
		
		var value = (sin(Globals.time - PI / 2.0) + 1.0) / 2.0
		self.color = gradient.gradient.sample(value)
		
		
	else:
		Globals.time += delta * ingame_to_real_minute_duration * ingame_speed  
		var value = (sin(Globals.time - PI / 2.0) + 1.0) / 2.0
		self.color = gradient.gradient.sample(value)
		
		_recalculate_time()


		
