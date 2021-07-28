extends Node

signal guilds_updated

func _ready() -> void:
	Utils.log('Utils.gd loaded.')

func log(text: String) -> void:
	if Variables.DEBUG:
		print(text)

func add_loading_info_and_redirect(loading_packets: Array, loading_redirect: String) -> void:
	Variables.target_loading_names = loading_packets
	Variables.target_redirect = loading_redirect
	
	get_tree().change_scene('res://assets/Scenes/Loading.tscn')

func save_credentials(traveller_email: String, traveller_password: String, is_in_guild: bool) -> void:
	Save.add_value('travellerEmail', traveller_email)
	Save.add_value('travellerPassword', traveller_password)
	Save.add_value('isInGuild', is_in_guild)

func find_not_in_and_remove(target: String, allowed_chars: String) -> String:
	var temp_str = target
	
	for letter in target:
		if not letter in allowed_chars:
			temp_str = temp_str.replace(letter, '')

	return temp_str

func update_guilds() -> void:
	if Save.get_value('isInGuild'):
		Socket.send_packet('currentGuild')
		
	else:
		Socket.send_packet('fetchGuilds')
	
	var result_response = yield(Socket, 'packet_fetched')
	
	if Save.get_value('isInGuild'):
		if is_event_reply(result_response['event']):
			Variables.current_guild = result_response['data']
			
			emit_signal('guilds_updated', true)
		
		else:
			emit_signal('guilds_updated', false)
		
	else:
		if is_event_reply(result_response['event']):
			for guild_id in result_response['data']['guildIds']:
				Socket.send_packet('fetchGuild', {'guildId': guild_id})
				
				Variables.fetched_guilds[guild_id] = yield(Socket, 'packet_fetched')
				
			emit_signal('guilds_updated', true)
				
		else:
			emit_signal('guilds_updated', false)

func is_event_reply(event: String) -> bool:
	return event.ends_with('Reply')
