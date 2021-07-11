extends Node

var file: File

func _ready() -> void:
	file = File.new()
	
	check_file()

func check_file() -> void:
	if not file.file_exists(Variables.SAVE_FILENAME):
		var file_result = file.open(Variables.SAVE_FILENAME, File.WRITE)
		
		if file_result == FAILED || file_result == ERR_FILE_NO_PERMISSION || file_result == ERR_FILE_ALREADY_IN_USE || file_result == ERR_FILE_CANT_WRITE:
			Utils.log('Error occured while attempting to create file, aborting.')
			get_tree().quit()
			
		file.store_line(JSON.print({}))
		file.close()

func add_value(key: String, value, set: bool = false) -> void:
	check_file()
	
	var file_dict = get_file_dict()
	
	if key in file_dict.keys() and not set:
		return

	file.open(Variables.SAVE_FILENAME, File.WRITE)

	file_dict[key] = value

	file.seek_end()

	file.store_line(JSON.print(file_dict))
	
	file.close()

func remove_value(key: String) -> void:
	check_file()
	
	var file_dict = get_file_dict()
	
	if not key in file_dict:
		return

	file.open(Variables.SAVE_FILENAME, File.WRITE)
	
	file_dict.erase(key)
	
	file.store_line(JSON.print(file_dict))
	
	file.close()

func get_value(key: String):
	check_file()
	
	var values_dict = get_file_dict()

	if key in values_dict:
		return values_dict[key]
	return null

func get_file_dict() -> Dictionary:
	check_file()
	
	file.open(Variables.SAVE_FILENAME, File.READ_WRITE)
	
	return JSON.parse(file.get_as_text()).result
