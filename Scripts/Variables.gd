extends Node

const WSS_URL = 'wss://towerverse.herokuapp.com'
const DEBUG = true
const SAVE_FILENAME = 'user://towerverse.bin'

# When encrypted saves are implemented
var SAVE_PASSWORD = OS.get_unique_id()

var loading_packets: Dictionary = {}
