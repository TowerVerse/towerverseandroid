extends Control

onready var loading_scene = get_node('.')
onready var loading_label = get_node('loading_label')
onready var loading_progress = get_node('loading_progress')
onready var tween = get_node('tween')

func _ready() -> void:
	Utils.log('Loading started.')
	
	fade_in()
		
	start_progress()

func fade_in():
	tween.interpolate_property(loading_scene, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4)
	tween.start()

func start_progress():
	loading_progress.value = 0
	
	if not Socket.is_connected:
		get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
		return
	
	process_packets()

func process_packets():
	if len(Variables.loading_packets) == 0:
		get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
		return
		
	var final_packet = {}
	var target_args = []
		
	var progress_to_add = 100.0 / len(Variables.loading_packets)
		
	for packet in Variables.loading_packets.values():
		loading_label.text = packet['text']
		
		final_packet = {}
		target_args = packet['target_args']
		
		packet.erase('text')
		packet.erase('target_args')

		for key in packet.keys():
			if not key == 'event':
				final_packet[key] = packet[key]
			
		Socket.send_packet(packet['event'], final_packet)
		
		var match_case_reply = packet['event'] + 'Reply'
		
		var result_response = yield(Socket, 'packet_fetched')
		
		match result_response['event']:
			match_case_reply:
				if 'callback' in packet:
					var target_args_arr = []
					
					for arg in target_args:
						target_args_arr.append(arg)
						
					packet['callback'].call_funcv(target_args_arr)

				loading_progress.value += progress_to_add
			_:
				Utils.log('Error calling ' + packet['event'] + ': '+ str(result_response))
				get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
				return
	
	loading_progress.value = 100
	
	loading_label.text = 'Finished.'
	
	Variables.loading_packets = {}
