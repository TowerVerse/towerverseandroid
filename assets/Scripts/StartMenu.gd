extends Control

onready var tween = get_node('tween')
onready var start_menu = get_node('.')

onready var play_button = get_node('button_container/play_button')
onready var options_button = get_node('button_container/options_button')
onready var about_button = get_node('button_container/about_button')

onready var version_label = get_node('version_container/version_label')

var button_translate_offset: float = -600

func _ready() -> void:
	Utils.log('StartMenu started.')
	
	version_label.text = Variables.APP_VERSION

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

# Signals
func _on_play_button_pressed() -> void:
	
	print('pr')
	
	var email = Save.get_value('travellerEmail')
	var password = Save.get_value('travellerPassword')
	
	if email && password:
		if not Socket.is_connected:
			return
			
		Utils.add_loading_packet('loginTraveller', 'res://assets/Scenes/OnlineMenu.tscn', {'travellerEmail': email,
													'travellerPassword': password},
								'Logging in...')
													
		get_tree().change_scene("res://assets/Scenes/Loading.tscn")
		
	else:
		get_tree().change_scene("res://assets/Scenes/Account.tscn")
