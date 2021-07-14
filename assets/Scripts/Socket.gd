extends Node

var _wss = WebSocketClient.new()

var _fetched_packets: Dictionary = {}

var is_connected: bool

signal towerverse_connected
signal fetch_added
signal packet_fetched

func _ready() -> void:
	Utils.log('Socket.gd loaded.')
	
	var connection_result = _wss.connect_to_url(Variables.WSS_URL)
	
	if connection_result != OK:
		is_connected = false
	
	_wss.set_target_peer(1)

	_wss.connect('connection_established', self, '_connection_established')
	_wss.connect('data_received', self, '_data_recieved')

func _process(_delta: float) -> void:
	if _wss.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	_wss.poll()

func _connection_established(_protocol: String):
	_wss.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	
	is_connected = true
	
	emit_signal('towerverse_connected')

func _data_recieved():
	var target_packet = JSON.parse(_wss.get_peer(1).get_packet().get_string_from_utf8()).result
	
	_fetched_packets[target_packet['ref']] = target_packet

	emit_signal('fetch_added')

func send_packet(event: String, data: Dictionary = {}) -> void:
	var final_packet_ref = Uuid.v4()
	
	var final_packet = {'event': event, 'ref': final_packet_ref}
	
	for key in data.keys():
		final_packet[key] = data[key]
		
	if not is_connected:
		yield(self, 'towerverse_connected')
		
	_send_wss_packet(_format_packet(final_packet))
	
	while not str(final_packet_ref) in _fetched_packets:
		yield(self, 'fetch_added')
	
	emit_signal('packet_fetched', _fetched_packets[final_packet_ref])

	_fetched_packets.erase(final_packet_ref)

func _send_wss_packet(packet: PoolByteArray) -> void:
	if not is_connected || _wss.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return
		
	elif is_connected:
		_wss.get_peer(1).put_packet(packet)

func _format_packet(data: Dictionary) -> PoolByteArray:
	return JSON.print(data).to_utf8()

func disconnect_socket():
	if is_connected:
		_wss.disconnect_from_host()
		is_connected = false

func connect_socket():
	if not is_connected:
		_wss.connect_to_url(Variables.WSS_URL)
