extends Node

const ENABLE_LOGGING = true
const LOG_TO_FILE = true # ENABLE_LOGGING must be enabled
const DEFAULT_LOG_PATH = "user://"
const DEFAULT_LOG_NAME = "logger"

# Use this on each script you wish to use the Logger
func get_logger(script_name, log_path = DEFAULT_LOG_PATH, log_file = DEFAULT_LOG_NAME):
	if(ENABLE_LOGGING):
		return Log.new(script_name, _get_file_writer(log_path, log_file))
	else:
		return DummyLog.new()

func _get_file_writer(log_path, log_file):
	if(LOG_TO_FILE):
		return FileWriter.new(log_path, log_file)
	else:
		return DummyFileWriter.new()


class Log:
	# GLOBAL DEFAULT LOGGING CONFIGURATION
	# - This can be overridden within each script that utilizes the log tool.
	var info_logging = true
	var debug_logging = true
	var warn_logging = true
	var error_logging = true
	
	# LOGGING 
	const LOG_FORMAT = "[{current_time}] | {level} | [{script_name}] [{function_name}] >> {msg}"
	
	# Logger script name
	var script_name = ""
	var current_function_name = ""
	
	var file_writer = null
	# Initializes the logger with the script name that is using it
	func _init(script_name = "", file_writer = null):
		self.script_name = script_name
		self.file_writer = file_writer
	
	# Used to set function name at teh beginning of each function, 
	# in order to populate the logger with function name
	func start(function_name):
		current_function_name = function_name
	
	func end():
		current_function_name = ""
	
	func info(message, function_name = ""):
		if(!info_logging):
			return
		var level = "INFO "
		_log(level, message, function_name)
		
	func debug(message, function_name = ""):
		if(!debug_logging):
			return
		var level = "DEBUG"
		_log(level, message, function_name)

	func warn(message, function_name = ""):
		if(!warn_logging):
			return
		var level = "WARN "
		_log(level, message, function_name)
		
	func error(message, function_name = ""):
		if(!error_logging):
			return
		var level = "ERROR"
		_log(level, message, function_name)
	
	func _log(level, message, function_name = ""):
		if(function_name.empty()):
			function_name = current_function_name
		var log_message = LOG_FORMAT.format({"level": level, "current_time": _get_current_time(), "script_name": script_name, "function_name": function_name, "msg": message})
		print(log_message)
		file_writer.write(log_message)
	
	func _get_current_time():
		var date_time = OS.get_datetime()
		var padding = 2
		_pad_zeros_in_dictionary(date_time, padding)
		
		# var time_format = "{year}.{month}." + ("{day}".pad_zeros(5)) + " - [{hour}:{minute}:{second}]"
		var time_format = "{year}.{month}.{day} {hour}:{minute}:{second}"
		return time_format.format(date_time)
	
	func _pad_zeros_in_dictionary(dictionary, padding):
		for key in dictionary:
			dictionary[key] = str(dictionary[key]).pad_zeros(padding)


class FileWriter:
	var file = null
	var full_file_path= ""
	
	func _init(file_path, file_name):
		self.full_file_path = file_path  + _get_current_time() + "-" + file_name + ".log"
		self.file = File.new()
		
		_create_file_if_not_exist()
	
	func _create_file_if_not_exist():
		if(!file.file_exists(full_file_path)):
			file.open(full_file_path, File.WRITE)
			file.close()
	
	func write(log_line):
		self.file.open(full_file_path, File.READ_WRITE)
		self.file.seek_end()
		self.file.store_line(log_line + "\n\r")
		self.file.close()
	
	func _get_current_time(): 
		var date_time = OS.get_datetime()
		var padding = 2
		_pad_zeros_in_dictionary(date_time, padding)
		var time_format = "{year}-{month}-{day}"
		return time_format.format(date_time)
	
	func _pad_zeros_in_dictionary(dictionary, padding):
		for key in dictionary:
			dictionary[key] = str(dictionary[key]).pad_zeros(padding)


# DummyFileWriter prevents writing a file when we have disabled file writing.
# An efficient way to disable functionality without affecting performance or having to make code changes.
class DummyFileWriter:
	func _init():
		pass
	
	func write(log_line):
		pass

# DummyLog prevents logging when we have disabled logging.
# An efficient way to disable functionality without affecting performance or having to make code changes.
class DummyLog:
	func _init():
		pass
	
	func start(function_name):
		pass
	
	func end():
		pass
	
	func info(message, function_name = ""):
		pass
	
	func debug(message, function_name = ""):
		pass
	
	func warn(message, function_name = ""):
		pass
	
	func error(message, function_name = ""):
		pass