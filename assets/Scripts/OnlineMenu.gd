extends Control

onready var tween = $tween
onready var tween2 = $tween_2
onready var online_menu = $'.'

onready var towers_container = $towers_container
onready var towers_label = $towers_container/towers_label

onready var guilds_container = $towers_container
onready var guilds_label = $guilds_container/guilds_label

# Create only
onready var guild_create_template_margin = $guilds_container/guild_create_margin
onready var guild_create_list_container = $guilds_container/guild_create_margin/guild_create_list
onready var guild_create_template = $guilds_container/guild_create_margin/guild_create_list/guild_create_template
onready var guild_create_member = $guilds_container/guild_create_margin/guild_create_list/guild_create_template/guild_create_template_vbox/guild_create_members/guild_create_member
onready var guild_create_button = $guilds_container/guilds_bottom_container/guild_create_button

# Current only
onready var guild_current_margin = $guilds_container/guild_current_margin
onready var guild_current_description = $guilds_container/guild_current_margin/guild_current_vbox/guild_current_description
onready var guild_chat_message = $guilds_container/guild_current_margin/guild_current_vbox/guild_current_grid/guild_current_chat_panel/guild_current_chat_vbox/guild_current_chat_container/guild_chat_message
onready var guild_send_button = $guilds_container/guild_current_margin/guild_current_vbox/guild_current_grid/guild_current_chat_panel/guild_current_chat_vbox/guild_current_chat_container/guild_send_button
onready var guild_leave_button = $guilds_container/guilds_bottom_container/guild_leave_button

var is_towers_tab: bool = false
var is_guilds_tab: bool = false

func _ready() -> void:
	Utils.log('OnlineMenu started.')
	
	restore_view_states()
	
	setup_ui_from_server_values()
	
	change_tab(1)

func _input(event):
	if event.is_action_released('ui_back'):
		if tween.is_active():
			return
		
		Socket.send_packet('logoutTraveller')
			
		get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if tween.is_active():
			return
		
		Socket.send_packet('logoutTraveller')
		
		get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")

func restore_view_states() -> void:
	guild_create_list_container.remove_child(guild_create_template)
	
	guild_create_template_margin.visible = false
	guild_current_margin.visible = false
	
	guild_create_button.visible = false
	guild_leave_button.visible = false

func disable_create() -> void:
	guild_create_button.disabled = true

func enable_create() -> void:
	guild_create_button.disabled = false

func disable_current() -> void:
	guild_leave_button.disabled = true

func enable_current() -> void:
	guild_leave_button.disabled = false

func fade_in_create_and_fade_out_current() -> void:
	disable_current()
	
	tween.interpolate_property(guild_leave_button, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	tween.start()
	
	yield(tween, 'tween_completed')
	
	guild_leave_button.visible = false
	
	disable_current()
	
	guild_create_template_margin.modulate.a = 0
	guild_create_template_margin.visible = true
	
	guild_create_button.modulate.a = 0
	guild_create_button.visible = true
	
	tween.interpolate_property(guild_create_template_margin, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	tween.start()
	
	tween2.interpolate_property(guild_create_button, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	tween2.start()
	
	enable_current()

func fade_out_create_and_fade_in_current() -> void:
	disable_create()
	
	tween.interpolate_property(guild_create_template_margin, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	tween.start()
	
	tween2.interpolate_property(guild_create_button, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	tween2.start()
	
	yield(tween2, 'tween_completed')
	
	guild_create_template_margin.visible = false
	guild_create_button.visible = false
	
	disable_current()
	
	guild_leave_button.modulate.a = 0
	guild_leave_button.visible = true
	
	tween.interpolate_property(guild_leave_button, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	tween.start()
	
	enable_current()

func setup_ui_from_server_values() -> void:
	Utils.update_guilds()
	
	yield(Utils, 'guilds_updated')
	
	var time_start = OS.get_ticks_msec()
	
	if Save.get_value('isInGuild'):
		guilds_label.text = Variables.current_guild['guildName']
		guild_current_description.text = Variables.current_guild['guildDescription']
		
		guild_create_template_margin.visible = false
		guild_create_button.visible = false
		
		guild_current_margin.visible = true
		guild_leave_button.visible = true
		
		Utils.log('setup_ui_from_server_values took ' + str(round(OS.get_ticks_msec() - time_start)) + ' ms.')
		
		return
	
	guild_current_margin.visible = false
	guild_leave_button.visible = false
	
	guilds_label.text = 'Available Guilds'
	
	for child in guild_create_list_container.get_children():
		guild_create_list_container.remove_child(child)
	
	for guild_id in Variables.fetched_guilds:
		Socket.send_packet('fetchGuild', {'guildId': guild_id})

		var result_response = yield(Socket, 'packet_fetched')['data']

		var temp_guild_container = guild_create_template.duplicate()
		
		var temp_description = temp_guild_container.get_child(0).get_child(0).get_child(0).get_child(0)
		var temp_members = temp_guild_container.get_child(0).get_child(0).get_child(0).get_child(1)
		
		var temp_members_container = temp_guild_container.get_child(0).get_child(1)
		
		var temp_join_button = temp_guild_container.get_child(0).get_child(2)
		
		temp_guild_container.name = result_response['guildName']
		
		temp_description.text = result_response['guildDescription']
		temp_members.text = 'Members: ' + str(len(result_response['guildMembers'])) + '/' + str(result_response['guildMaxMembers'])
		
		if len(result_response['guildMembers']) == int(result_response['guildMaxMembers']):
			temp_join_button.disabled = true
		
		else:
			temp_join_button.connect('pressed', self, 'join_guild', [result_response['guildId']])
		
		for traveller_id in result_response['guildMembers']:
			Socket.send_packet('fetchTraveller', {'travellerId': traveller_id})
			
			var result_member_response = yield(Socket, 'packet_fetched')['data']
			
			var temp_member_button = guild_create_member.duplicate()
			
			temp_member_button.text = result_member_response['travellerName']
			
			# Todo: when home towers are implemented
#			connect('pressed', temp_member_button)
			
			temp_members_container.add_child(temp_member_button)
		
		temp_members_container.remove_child(temp_members_container.get_child(0))
		
		guild_create_list_container.add_child(temp_guild_container)
	
	if guild_create_list_container.get_child_count() == 0:
		guilds_label.text = 'No guilds found.'
		
	else:
		guild_create_template_margin.visible = true
		
	guild_create_button.visible = true
		
	Utils.log('setup_ui_from_server_values took ' + str(round(OS.get_ticks_msec() - time_start)) + ' ms.')

func change_tab(tab_num: int) -> void:
	match tab_num:
		0:
			if not is_towers_tab:
				towers_container.visible = true
				
				guilds_container.visible = false
				
				#todo: yield and change variable states
				is_towers_tab = true
				is_guilds_tab = false
		1:
			if not is_guilds_tab:
				guilds_container.visible = true
				
				towers_container.visible = false
				
				is_guilds_tab = true
				is_towers_tab = false
				
		_:
			Utils.log('Invalid tab number provided to change_tab: ' + str(tab_num))

# Signals
func _on_bottom_guilds_button_pressed():
	change_tab(1)

func _on_guilds_create_button_pressed():
	# Todo: dialog custom layouts, testing
	Socket.send_packet('createGuild', {'guildName': 'test guild' + str(rand_range(1, 10)), 'guildDescription': 'this is a description',
																			'guildVisibility': 'public', 'guildMaxMembers': '2'})
																			
	if Utils.is_event_reply(yield(Socket, 'packet_fetched')['event']):
		Save.set_value('isInGuild', true)
		
		setup_ui_from_server_values()

func _on_guild_leave_button_pressed():
	Socket.send_packet('leaveGuild')
	
	if Utils.is_event_reply(yield(Socket, 'packet_fetched')['event']):
		Save.set_value('isInGuild', false)
		
		setup_ui_from_server_values()

func join_guild(guild_id: String) -> void:
	Socket.send_packet('joinGuild', {'guildId': guild_id})
	
	if Utils.is_event_reply(yield(Socket, 'packet_fetched')['event']):
		Save.set_value('isInGuild', true)
		
		setup_ui_from_server_values()

func _on_guild_chat_message_text_changed(new_text):
		var prev_caret_pos = guild_chat_message.caret_position
		

		if len(new_text) > Variables.max_chat_message_length:
			guild_chat_message.text = new_text.substr(0, Variables.max_chat_message_length)
			
		guild_chat_message.caret_position = prev_caret_pos
