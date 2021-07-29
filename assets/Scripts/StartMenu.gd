extends Control

onready var tween = $tween
onready var tween2 = $tween_2

onready var start_menu = $'.'

onready var play_button = $button_container/play_button
onready var options_button = $button_container/options_button
onready var about_button = $button_container/about_button

onready var bottom_container = $bottom_container
onready var gameinfo_need_account_label = $bottom_container/gameinfo_need_account_label
onready var gameinfo_expand_button = $bottom_container/gameinfo_expand_button
onready var gameinfo_scrollbar = $bottom_container/gameinfo_scrollbar
onready var gameinfo_label = $bottom_container/gameinfo_scrollbar/gameinfo_label

var email = ''
var password = ''

func _ready() -> void:
	Utils.log('StartMenu started.')
	
	restore_view_states()

func restore_view_states() -> void:
	gameinfo_scrollbar.visible = false
	
	email = Save.get_value('travellerEmail')
	password = Save.get_value('travellerPassword')
	
	if not email || not password:
		gameinfo_need_account_label.visible = true
		gameinfo_expand_button.visible = false
		
	else:
		gameinfo_expand_button.visible = true
		gameinfo_need_account_label.visible = false

func _input(event: InputEvent):
	if event.is_action_released('ui_back'):
		get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

# Signals
func _on_play_button_pressed() -> void:
	if email && password:
		if not Socket.is_connected:
			return
			
		Utils.add_loading_info_and_redirect(['login'], 'res://assets/Scenes/OnlineMenu.tscn')
	else:
		get_tree().change_scene("res://assets/Scenes/Account.tscn")

func _on_patchnotes_expand_button_pressed():
	tween.interpolate_property(gameinfo_expand_button, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1)
	tween.start()
	
	tween2.interpolate_property(bottom_container, 'margin_top', -80, -250, 1, Tween.TRANS_EXPO)
	tween2.start()
	
	yield(tween2, 'tween_completed')
	
	gameinfo_label.modulate.a = 0
	gameinfo_scrollbar.visible = true
	gameinfo_label.visible = true
	
	gameinfo_expand_button.visible = false
	
	tween2.interpolate_property(gameinfo_label, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1)
	tween2.start()
