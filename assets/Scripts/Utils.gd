extends Node

func _ready() -> void:
	Utils.log('Utils.gd loaded.')

func log(text: String) -> void:
	if Variables.DEBUG:
		print(text)

func add_loading_packet(event: String, data: Dictionary = {}, loading_text: String = 'Loading...', callback: FuncRef = null, target_args: Array = []):
	var final_packet = {'event': event, 'text': loading_text, 'target_args': target_args}
	
	for key in data.keys():
		final_packet[key] = data[key]
	
	if callback:
		final_packet['callback'] = callback
	
	Variables.loading_packets[len(Variables.loading_packets)] = final_packet

func get_item_index(data: Dictionary, key):
	for i in range(data.size()):
		if data[i] == key:
			return i

func save_credentials(travellerName: String, travellerPassword: String):
	Save.add_value('travellerEmail', travellerName)
	Save.add_value('travellerPassword', travellerPassword)
