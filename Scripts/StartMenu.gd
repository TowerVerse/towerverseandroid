extends Control

onready var tween = get_node('tween')
onready var start_menu = get_node('.')

func _ready() -> void:
	Utils.log('StartMenu started.')
	
	fade_in()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

func _on_play_button_pressed() -> void:
	
	get_tree().change_scene("res://Scenes/Account.tscn")

func fade_in():
	tween.interpolate_property(start_menu, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1)
	tween.start()
