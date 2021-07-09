extends Control

onready var tween = get_node('tween')
onready var account_scene = get_node('.')

onready var account_buttons_container = get_node('account_buttons_container')

onready var register_container = get_node('register_container')
onready var register_username = get_node('register_container/register_username_container/register_username')
onready var register_email = get_node('register_container/register_email_container/register_email')
onready var register_password = get_node('register_container/register_password_container/register_password')

onready var login_container = get_node('login_container')
onready var login_email = get_node('login_container/login_email_container/login_email')
onready var login_password = get_node('login_container/login_password_container/login_password')

var has_selected: bool = false
var is_register: bool = false

func _ready() -> void:
	Utils.log('Account started.')
	
	fade_in()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_back'):
		if not has_selected:
			get_tree().change_scene("res://Scenes/StartMenu.tscn")
		has_selected = false
		fade_in_buttons_and_fade_out_ui()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if not has_selected:
			get_tree().change_scene("res://Scenes/StartMenu.tscn")
		has_selected = false
		fade_in_buttons_and_fade_out_ui()
	
func fade_in():
	register_container.visible = false
	
	tween.interpolate_property(account_scene, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1)
	tween.start()

func fade_in_buttons_and_fade_out_ui():
	if is_register:
		tween.interpolate_property(register_container, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25)
		tween.start()
		
	else:
		tween.interpolate_property(login_container, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25)
		tween.start()
	
	yield(tween, 'tween_completed')
	
	if is_register:
		register_container.visible = false
		
	else:
		login_container.visible = false
		
	tween.interpolate_property(account_buttons_container, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25)
	tween.start()

func fade_out_buttons_and_fade_in_ui():
	tween.interpolate_property(account_buttons_container, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25)
	tween.start()
	
	yield(tween, 'tween_completed')
	
	if is_register:
		register_container.modulate.a = 0
		register_container.visible = true
		tween.interpolate_property(register_container, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25)
		tween.start()
	else:
		login_container.modulate.a = 0
		login_container.visible = true
		tween.interpolate_property(login_container, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25)
		tween.start()

func _on_acc_register_button_pressed() -> void:
	has_selected = true
	is_register = true
	fade_out_buttons_and_fade_in_ui()

func _on_acc_login_button_pressed() -> void:
	has_selected = true
	is_register = false
	fade_out_buttons_and_fade_in_ui()

func _on_register_button_pressed() -> void:
	var username = register_username.text
	var email = register_email.text
	var password = register_password.text
	var error_text = ''
	
	if username.length() < 3 || username.length() > 20:
		error_text = 'Username should be between 3 and 20 characters.'
		
	elif email.length() < 10 || email.length() > 60:
		error_text = 'Email should be between 10 and 60 characters.'
		
	elif password.length() < 10 || password.length() > 50:
		error_text = 'Password should be between 10 and 50 characters.'

	else:
		Socket.send_packet('createTraveller', {
								'travellerName': username,
								'travellerEmail': email,
								'travellerPassword': password
		})
		
		var result_response = yield(Socket, 'packet_fetched')
		var result_response_reply = 'createTravellerReply'
		
		match result_response['event']:
			result_response_reply:
				Utils.save_credentials(email, password)
				get_tree().change_scene("res://Scenes/StartMenu.tscn")
			_:
				error_text = result_response

	if error_text:
		print(error_text)
		
	error_text = ''

func _on_login_button_pressed() -> void:
	var email = login_email.text
	var password = login_password.text
	var error_text = ''
		
	if email.length() < 10 || email.length() > 60:
		error_text = 'Email should be between 10 and 60 characters.'
		
	elif password.length() < 10 || password.length() > 50:
		error_text = 'Password should be between 10 and 50 characters.'

	else:
		Socket.send_packet('loginTraveller', {
								'travellerEmail': email,
								'travellerPassword': password
		})
		
		var result_response = yield(Socket, 'packet_fetched')
		var result_response_reply = 'loginTravellerReply'
		
		match result_response['event']:
			result_response_reply:
				Utils.save_credentials(email, password)
				get_tree().change_scene("res://Scenes/StartMenu.tscn")
			_:
				error_text = result_response
		
	error_text = ''
