extends Control

onready var tween = get_node('tween')
onready var account_scene = get_node('.')

onready var account_buttons_container = get_node('account_buttons_container')
onready var acc_register_button = get_node('account_buttons_container/acc_register_button')
onready var acc_login_button = get_node('account_buttons_container/acc_login_button')

onready var register_container = get_node('register_container')
onready var register_error_label = get_node('register_container/register_error_label')
onready var register_username = get_node('register_container/register_username')
onready var register_email = get_node('register_container/register_email')
onready var register_password = get_node('register_container/register_password')
onready var register_button = get_node('register_container/register_button')

onready var login_container = get_node('login_container')
onready var login_error_label = get_node('login_container/login_error_label')
onready var login_email = get_node('login_container/login_email')
onready var login_password = get_node('login_container/login_password')
onready var login_button = get_node('login_container/login_button')

onready var verification_container = get_node('verification_container')
onready var verification_error_label = get_node('verification_container/verification_error_label')
onready var verification_code = get_node('verification_container/verification_code')
onready var verification_button = get_node('verification_container/verification_button')

var has_selected: bool = false
var is_register: bool = false
var is_verification: bool = false
var is_handling: bool = false

func _ready() -> void:
	Utils.log('Account started.')
	
	account_buttons_container.visible = true
	
	register_container.visible = false
	register_error_label.visible = false
	
	verification_container.visible = false
	verification_error_label.visible = false
	
	login_container.visible = false
	login_error_label.visible = false

# PC testing, no effect on mobile
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_back'):
		if tween.is_active() || is_verification || is_handling:
			return
			
		if not has_selected:
			get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
			
		else:
			has_selected = false
			fade_in_buttons_and_fade_out_ui()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if tween.is_active() || is_verification || is_handling:
			return
			
		if not has_selected:
			get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
			
		else:
			has_selected = false
			fade_in_buttons_and_fade_out_ui()

func fade_in_buttons_and_fade_out_ui() -> void:
	if is_register:
		disable_register()
		tween.interpolate_property(register_container, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25)
		tween.start()
		
	else:
		disable_login()
		tween.interpolate_property(login_container, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25)
		tween.start()
	
	yield(tween, 'tween_completed')
	
	if is_register:
		register_container.visible = false
		
	else:
		login_container.visible = false
		
	tween.interpolate_property(account_buttons_container, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25)
	tween.start()
	
	yield(tween ,"tween_completed")
	
	acc_register_button.disabled = false
	acc_login_button.disabled = false

func fade_out_buttons_and_fade_in_ui() -> void:
	acc_register_button.disabled = true
	acc_login_button.disabled = true
	
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
		
	yield(tween, "tween_completed")
	
	if is_register:
		enable_register()
		
	else:
		enable_login()

func fade_out_register_and_fade_in_verification() -> void:
	disable_register()
	
	tween.interpolate_property(register_container, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25)
	tween.start()
	
	yield(tween, "tween_completed")
	
	verification_container.modulate.a = 0
	verification_container.visible = true
	tween.interpolate_property(verification_container, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25)
	tween.start()

	verification_code.editable = true
	verification_button.disabled = false

func show_response_error(dict: Dictionary) -> void:
	if is_register and not is_verification:
		var register_error_text = ''
	
		match dict['event']:
			'createTravellerNameExceedsLimit':
				register_error_text = Templates.exceeds_length % ['Username', '3', '20']
				register_username.grab_focus()
				
			'createTravellerEmailExceedsLimit':
				register_error_text = Templates.exceeds_length % ['Email', '10', '60']
				register_email.grab_focus()
			'createTravellerEmailInvalidFormat':
				register_error_text = dict['data']['errorMessage']
				register_email.grab_focus()
			'createTravellerEmailInUse':
				register_error_text = Templates.email_in_use
				register_email.grab_focus()
				
			'createTravellerPasswordExceedsLimit':
				register_error_text = Templates.exceeds_length % ['Password', '10', '50']
				register_password.grab_focus()
				
			_:
				register_error_text = Templates.unknown_error % ['registering']
				
		register_error_label.visible = true
		register_error_label.text = register_error_text
	
	elif is_verification:
		var verification_error_text = ''
		
		match dict['event']:
			'verifyTravellerCodeExceedsLimit':
				verification_error_text = Templates.exact_length % ['Verification code', '6']
				verification_code.grab_focus()
			'verifyTravellerInvalidCode':
				verification_error_text = Templates.invalid_verification_code
				verification_code.grab_focus()
				
			_:
				verification_error_text = Templates.unknown_error % ['verifying']
				
		verification_error_label.visible = true
		verification_error_label.text = verification_error_text
		
	else:
		var login_error_text = ''
		
		match dict['event']:
			'loginTravellerEmailExceedsLimit':
				login_error_text = Templates.exceeds_length % ['Email', '10', '60']
				login_email.grab_focus()
			'loginTravellerEmailInvalidFormat':
				login_error_text = dict['data']['errorMessage']
				login_email.grab_focus()
			
			'loginTravellerPasswordExceedsLimit':
				login_error_text = Templates.exceeds_length % ['Password', '10', '50']
				login_password.grab_focus()
		
			'loginTravellerNotFound':
				login_error_text = 'The traveller could not be found.'
				login_email.grab_focus()
			
			'loginTravellerAccountTaken':
				login_error_text = 'Someone else has already logged in to this account.'
				login_email.grab_focus()
				
			'loginTravellerInvalidPassword':
				login_error_text = 'The password is invalid.'
				login_password.grab_focus()

			_:
				login_error_text = Templates.unknown_error % ['logging in']
		
		login_error_label.visible = true
		login_error_label.text = login_error_text

func disable_register() -> void:
	register_username.editable = false
	register_email.editable = false
	register_password.editable = false
	register_button.disabled = true

func enable_register() -> void:
	register_username.editable = true
	register_email.editable = true
	register_password.editable = true
	register_button.disabled = false

func disable_verification() -> void:
	verification_code.editable = false
	verification_button.disabled = true

func enable_verification() -> void:
	verification_code.editable = true
	verification_button.disabled = false

func disable_login() -> void:
	login_email.editable = false
	login_password.editable = false
	login_button.disabled = true

func enable_login() -> void:
	login_email.editable = true
	login_password.editable = true
	login_button.disabled = false

# Signals
func _on_acc_register_button_pressed() -> void:
	has_selected = true
	is_register = true
	fade_out_buttons_and_fade_in_ui()

func _on_acc_login_button_pressed() -> void:
	has_selected = true
	is_register = false
	fade_out_buttons_and_fade_in_ui()

func _on_register_button_pressed() -> void:
	is_handling = true
	disable_register()
	
	var username = register_username.text
	var email = register_email.text
	var password = register_password.text
	
	if username.empty() || email.empty() || password.empty():
		register_error_label.visible = true
		register_error_label.text = 'Username, email or password mustn\'t be empty.'
		enable_register()
		is_handling = false
		return

	Socket.send_packet('createTraveller', {
							'travellerName': username,
							'travellerEmail': email,
							'travellerPassword': password
	})
	
	var result_response = yield(Socket, 'packet_fetched')
	
	match result_response['event']:
		'createTravellerReply':
			is_verification = true
			fade_out_register_and_fade_in_verification()
		_:
			show_response_error(result_response)

	enable_register()
	is_handling = false

func _on_login_button_pressed() -> void:
	is_handling = true
	disable_login()
	
	var email = login_email.text
	var password = login_password.text
	
	if email.empty() || password.empty():
		login_error_label.visible = true
		login_error_label.text = 'Email or password mustn\'t be empty.'
		enable_login()
		is_handling = false
		return
	
	Socket.send_packet('loginTraveller', {
							'travellerEmail': email,
							'travellerPassword': password
	})
	
	var result_response = yield(Socket, 'packet_fetched')
	
	match result_response['event']:
		'loginTravellerReply':
			Utils.save_credentials(email, password)
			get_tree().change_scene("res://assets/Scenes/OnlineMenu.tscn")
		_:
			show_response_error(result_response)

	enable_login()
	is_handling = false

func _on_verification_button_pressed():
	is_handling = true
	disable_verification()
	
	var email = register_email.text
	var password = register_password.text
	var code = verification_code.text
	
	if code.empty():
		verification_error_label.visible = true
		verification_error_label.text = 'Verification code mustn\'t be empty.'
		enable_verification()
		is_handling = false
		return
		
	Socket.send_packet('verifyTraveller', {'travellerEmail': email,
											'travellerCode': code
	})
	
	var result_response = yield(Socket, 'packet_fetched')
	
	match result_response['event']:
		'verifyTravellerReply':
			Utils.save_credentials(email, password)
			get_tree().change_scene("res://assets/Scenes/OnlineMenu.tscn")
		_:
			show_response_error(result_response)

	enable_verification()
	is_handling = false

func _on_register_username_text_changed(new_text):
	var prev_caret_pos = register_username.caret_position
	register_username.text = Utils.find_not_in_and_remove(new_text, Variables.username_characters)
	register_username.caret_position = prev_caret_pos

func _on_register_email_text_changed(new_text):
	var prev_caret_pos = register_email.caret_position
	register_email.text = Utils.find_not_in_and_remove(new_text, Variables.email_characters)
	register_email.caret_position = prev_caret_pos

func _on_register_password_text_changed(new_text):
	var prev_caret_pos = register_password.caret_position
	register_password.text = Utils.find_not_in_and_remove(new_text, Variables.password_characters)
	register_password.caret_position = prev_caret_pos

func _on_login_email_text_changed(new_text):
	var prev_caret_pos = login_email.caret_position
	login_email.text = Utils.find_not_in_and_remove(new_text, Variables.email_characters)
	login_email.caret_position = prev_caret_pos

func _on_login_password_text_changed(new_text):
	var prev_caret_pos = login_password.caret_position
	login_password.text = Utils.find_not_in_and_remove(new_text, Variables.password_characters)
	login_password.caret_position = prev_caret_pos

func _on_verification_code_text_changed(new_text):
	var prev_caret_pos = verification_code.caret_position
	verification_code.text = Utils.find_not_in_and_remove(new_text, Variables.digits)
	verification_code.caret_position = prev_caret_pos
