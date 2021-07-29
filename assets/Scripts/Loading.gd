extends Control

onready var loading_scene = $'.'

onready var loading_label = $loading_label
onready var loading_progress = $loading_progress

var packet_succeeded: bool = false

signal packet_finished

func _ready() -> void:
	Utils.log('Loading started.')
		
	start_progress()

func start_progress():
	loading_progress.value = 0
	
	if not Socket.is_connected:
		get_tree().change_scene("res://assets/Scenes/StartMenu.tscn")
		return
	
	process_loading_packets()

func process_loading_packets() -> void:
	
	if not Variables.target_loading_names:
		Utils.log('No loading packet names passed to Loading, aborting.')
		exit_loading()
		return
	
	var progress_to_add = 100.0 / len(Variables.target_loading_names)
	
	for packet in Variables.target_loading_names:
		var target_func = funcref(self, packet)
		
		if not target_func.is_valid():
			Utils.log('Invalid loading packet name provided to Loading, aborting.')
			exit_loading()
			return
		
		target_func.call_func()
		
		if not yield(self, 'packet_finished'):
			exit_loading()
			return
		
		loading_progress.value += progress_to_add
	
	var temp_redirect = Variables.target_redirect
	
	if not temp_redirect:
		Utils.log('No loading redirect provided to Loading, aborting.')
		exit_loading()
		return
	
	cleanup_loading_variables()
	
	get_tree().change_scene(temp_redirect)

func login() -> void:
	loading_label.text = 'Logging in to TowerVerse servers...'
	
	Socket.send_packet('loginTraveller', {'travellerEmail': Save.get_value('travellerEmail'),
										'travellerPassword': Save.get_value('travellerPassword')})
													
	emit_signal('packet_finished', Utils.is_event_reply(yield(Socket, 'packet_fetched')['event']))

func guilds() -> void:
	loading_label.text = 'Updating guilds...'
	
	Utils.update_guilds()
	
	yield(Utils, 'guilds_updated')
	
	emit_signal('packet_finished', true)

func cleanup_loading_variables() -> void:
	Variables.target_loading_names = []
	Variables.target_redirect = ''

func exit_loading() -> void:
	cleanup_loading_variables()
	get_tree().change_scene('res://assets/Scenes/StartMenu.tscn')
