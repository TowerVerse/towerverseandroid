extends Node

var file: File

func _ready() -> void:
	file = File.new()
	
	check_file()

func check_file() -> void:
	if not file.file_exists(Variables.SAVE_FILENAME):
		var file_result = file.open_encrypted_with_pass(Variables.SAVE_FILENAME, File.WRITE, Variables.SAVE_PASSWORD)
		
		if file_result == FAILED || file_result == ERR_FILE_NO_PERMISSION || file_result == ERR_FILE_ALREADY_IN_USE || file_result == ERR_FILE_CANT_WRITE:
			Utils.log('Error occured while attempting to create file, aborting.')
			get_tree().quit()
			
		file.store_line(JSON.print({}))
		file.close()

func add_value(key: String, value) -> void:
	check_file()
	
	var file_dict = get_file_dict()
	
	if key in file_dict.keys():
		Utils.log('Can\'t add ' + key + ', it already exists in the save file, aborting.')
		return

	file.open_encrypted_with_pass(Variables.SAVE_FILENAME, File.WRITE, Variables.SAVE_PASSWORD)

	file_dict[key] = value

	file.seek_end()

	file.store_line(JSON.print(file_dict))
	
	file.close()

func set_value(key: String, value) -> void:
	check_file()
	
	var file_dict = get_file_dict()
	
	if not key in file_dict.keys():
		Utils.log('Can\'t set ' + key + ', it doesn\'t exist in the save file, aborting.')
		return
		
	file.open_encrypted_with_pass(Variables.SAVE_FILENAME, File.WRITE, Variables.SAVE_PASSWORD)
	
	file_dict[key] = value
	
	file.seek_end()
	
	file.store_line(JSON.print(file_dict))
	
	file.close()

func remove_value(key: String) -> void:
	check_file()
	
	var file_dict = get_file_dict()
	
	if not key in file_dict:
		Utils.log('Can\'t remove ' + key + ', it doesn\'t exist in the save file, aborting.')
		return

	file.open_encrypted_with_pass(Variables.SAVE_FILENAME, File.WRITE, Variables.SAVE_PASSWORD)
	
	file_dict.erase(key)
	
	file.store_line(JSON.print(file_dict))
	
	file.close()

func get_value(key: String):
	check_file()
	
	var values_dict = get_file_dict()

	if not key in values_dict:
		Utils.log('Can\'t get ' + key + ', it doesn\'t exist in the save file, aborting.')
		return null
	
	return values_dict[key]

func get_file_dict() -> Dictionary:
	check_file()
	
	var temp_file = File.new()
	
	temp_file.open_encrypted_with_pass(Variables.SAVE_FILENAME, File.READ, Variables.SAVE_PASSWORD)
	
	return JSON.parse(temp_file.get_as_text()).result
