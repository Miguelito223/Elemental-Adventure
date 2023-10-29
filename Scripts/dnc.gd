extends CanvasModulate

var minutes_per_day = 1440
var minutes_per_hour = 60
var ingame_to_real_minute_duration = (2 * PI) / minutes_per_day

signal time_tick(day,hour,minute)

@export var gradient:GradientTexture1D
@export var ingame_speed = int(Globals.time_speed)
@export var initial_hour = int(Globals.initial_time):
	set(h):
		initial_hour = h
		time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour

var time = 0.0
var past_minute = -1.0
var time_data = {}

func _ready():
	
	time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour

func _process(delta):
	time += delta * ingame_to_real_minute_duration * ingame_speed  
	var value = (sin(time - PI / 2) + 1.0 / 2.0)
	self.color = gradient.gradient.sample(value)
	
	_recalculate_time()


func _recalculate_time():
	var total_minutes = int(time / ingame_to_real_minute_duration)
	var day = int(total_minutes / minutes_per_day)

	var current_day_minutes = total_minutes % minutes_per_day
	var hours = int(current_day_minutes / minutes_per_hour)
	var minute = int(current_day_minutes % minutes_per_hour)

	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day, hours, minute)
		Globals.day = day
		Globals.hour = hours
		Globals.minute = minute
