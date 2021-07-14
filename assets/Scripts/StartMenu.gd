extends Control

onready var tween = get_node('tween')
onready var start_menu = get_node('.')
onready var version_label = get_node('version_container/version_label')

func _ready() -> void:
	Utils.log('StartMenu started.')
	
	fade_in()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

func fade_in():
	version_label.text = Variables.APP_VERSION
	
	tween.interpolate_property(start_menu, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1)
	tween.start()

# Signals
func _on_play_button_pressed() -> void:
	
	var email = Save.get_value('travellerEmail')
	var password = Save.get_value('travellerPassword')
	
	if email && password:
		if not Socket.is_connected:
			return
			
		Utils.add_loading_packet('loginTraveller', {'travellerEmail': email,
													'travellerPassword': password},
								'Logging in...')
													
		get_tree().change_scene("res://assets/Scenes/Loading.tscn")
		
	else:
		get_tree().change_scene("res://assets/Scenes/Account.tscn")
