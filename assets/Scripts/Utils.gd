extends Node

func _ready() -> void:
	Utils.log('Utils.gd loaded.')

func log(text: String) -> void:
	if Variables.DEBUG:
		print(text)

func add_loading_packet(event: String, redirect: String, data: Dictionary = {}, loading_text: String = 'Loading...', callback: FuncRef = null, target_args: Array = []):
	var final_packet = {}
	
	for key in data.keys():
		final_packet[key] = data[key]
	
	final_packet['event'] = event
	final_packet['text'] = loading_text
	final_packet['target_args'] = target_args
	
	if callback:
		final_packet['callback'] = callback
	
	Variables.loading_packets[len(Variables.loading_packets)] = final_packet
	Variables.loading_redirect = redirect

func save_credentials(travellerEmail: String, travellerPassword: String):
	Save.add_value('travellerEmail', travellerEmail)
	Save.add_value('travellerPassword', travellerPassword)

func find_not_in_and_remove(target: String, allowed_chars: String) -> String:
	var temp_str = target
	
	for letter in target:
		if not letter in allowed_chars:
			temp_str = temp_str.replace(letter, '')

	return temp_str
