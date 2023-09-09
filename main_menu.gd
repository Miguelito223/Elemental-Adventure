extends Control

@onready var main_menu = $"main menu"
@onready var settings_menu = $"settings menu"
@onready var master_volume = $"settings menu/master volume"
@onready var fx_volume = $"settings menu/Fx volume"
@onready var music_volume = $"settings menu/music volume"
@onready var fullscreen = $"settings menu/fullscreen tongle"
@onready var resolutions = $"settings menu/resolution"
@onready var initial_time = $"settings menu/initial time text"
@onready var time_speed = $"settings menu/time speed text"

var resolution = {
	"1920x1080": Vector2i(1920, 1080),
	"1600x1200": Vector2i(1600, 1200),
	"1400x1050	": Vector2i(1400, 1050)
}
	
func addresolutions():
	var current_resolution = get_viewport().get_size()
	var index = 0
	
	for r in resolution:
		resolutions.add_item(r,index)
		
		if resolution[r] == current_resolution:
			resolutions._select_int(index)
		index += 1

func _ready():
	master_volume.value = SettingsData.settingsdata.master_volume
	fx_volume.value = SettingsData.settingsdata.fx_volume
	music_volume.value = SettingsData.settingsdata.music_volume
	fullscreen.button_pressed = SettingsData.settingsdata.fullscreen
	initial_time.text = SettingsData.settingsdata.initial_time
	time_speed.text = SettingsData.settingsdata.time_speed
	addresolutions()
	
func _on_play_pressed():
	PlayerData.remove_file()
	PlayerData.save_file()
	Global.load_scene(self, "res://level_1.tscn")
	

func _on_option_pressed():
	main_menu.hide()
	settings_menu.show()


func _on_exit_pressed():
	get_tree().quit()
	
func _on_master_volume_value_changed(value):
	SettingsData.load_volume(0, value)

func _on_back_pressed():
	main_menu.show()
	settings_menu.hide()


func _on_load_pressed():
	PlayerData.load_file()
	Global.load_scene(self, PlayerData.playerdata.level)

func _on_fullscreen_tongle_toggled(button_pressed):
	SettingsData.load_fullscreen(button_pressed)

func _on_option_button_item_selected(index):
	var size = resolution.get(resolutions.get_item_text(index))
	SettingsData.load_resolution(size)


func _on_fx_volume_value_changed(value):
	SettingsData.load_volume(2, value)


func _on_music_volume_value_changed(value):
	SettingsData.load_volume(1, value)


func _on_time_speed_text_text_changed(new_text):
	SettingsData.settingsdata.time_speed = new_text
	SettingsData.save_file()


func _on_initial_time_text_text_changed(new_text):
	SettingsData.settingsdata.initial_time = new_text 
	SettingsData.save_file()
