extends Node

const APP_VERSION = '0.2a1'
const WSS_URL = 'wss://towerverse.herokuapp.com'
const DEBUG = true
const SAVE_FILENAME = 'user://towerverse.bin'

# When encrypted saves are implemented
var SAVE_PASSWORD = OS.get_unique_id()

var loading_packets: Dictionary = {}

var ascii_letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
var digits = '1234567890'

var username_characters = ascii_letters + digits + '!^*'
var email_characters = ascii_letters + digits + '@.'
var password_characters = ascii_letters + digits + '`~!@#$%^&*()-_=+[{]}\\|;:\'",<.>/?'
