extends Node

# General variables
const APP_VERSION = '0.2a1'
const WSS_URL = 'wss://towerverse.herokuapp.com'
const DEBUG = true

const SAVE_FILENAME = 'user://towerverse.bin'
var SAVE_PASSWORD = OS.get_unique_id()

var target_loading_names: Array = []
var target_redirect: String = ''

# Account variables
var ascii_letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
var digits = '1234567890'

var username_characters = ascii_letters + digits + '!^*'
var max_username_length = 20

var email_characters = ascii_letters + digits + '@.'
var max_email_length = 60

var password_characters = ascii_letters + digits + '`~!@#$%^&*()-_=+[{]}\\|;:\'",<.>/?'
var max_password_length = 50

var max_verification_code_length = 6

var max_chat_message_length = 100

# Filled in
var fetched_guilds: Dictionary = {}
var current_guild: Dictionary = {}
