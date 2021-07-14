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
		
	var event = ''
	var final_packet = {}
	var callback: FuncRef = null
	var target_args = []
		
	var progress_to_add = 100.0 / len(Variables.loading_packets)
		
	for packet in Variables.loading_packets.values():
		loading_label.text = packet['text']
		
		event = packet['event']
		final_packet = {}
		callback = null
		target_args = packet['target_args']
		
		if 'callback' in packet:
			callback = packet['callback']
		
		packet.erase('event')
		packet.erase('text')
		packet.erase('callback')
		packet.erase('target_args')

		for key in packet.keys():
			final_packet[key] = packet[key]
			
		Socket.send_packet(event, final_packet)
		
		var match_case_reply = event + 'Reply'
		
		var result_response = yield(Socket, 'packet_fetched')
		
		match result_response['event']:
			match_case_reply:
				if callback:
					callback.call_funcv(target_args)

				loading_progress.value += progress_to_add
			_:
				Utils.log('Error calling ' + event + ': '+ str(result_response))
				get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
				return
	
	loading_progress.value = 100
	
	loading_label.text = 'Finished.'
	
	Variables.loading_packets = {}
