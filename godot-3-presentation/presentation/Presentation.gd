extends Node

signal language_changed()

@onready var slides = $Slides
@export_enum('en', 'ja', 'fr', 'es', 'pt_BR', 'de', 'it') var LANGUAGE_MAIN := 'en'
@export_enum('en', 'ja', 'fr', 'es', 'pt_BR', 'de', 'it') var LANGUAGE_SECOND := 'ja'

func _ready():
	TranslationServer.set_locale(LANGUAGE_MAIN)
	slides.initialize()
#	save_as_csv(get_translatable_strings()) # Use this to save the presentation as CSV

func _input(event):
	if LANGUAGE_MAIN == LANGUAGE_SECOND:
		return
	if event.is_action_pressed('change_language'):
		if TranslationServer.get_locale() == LANGUAGE_MAIN:
			change_language(LANGUAGE_SECOND)
		else:
			change_language(LANGUAGE_MAIN)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed(&"ui_right"):
		slides.display(slides.DIRECTIONS.NEXT)
	if event.is_action_pressed(&"ui_left"):
		slides.display(slides.DIRECTIONS.PREVIOUS)


func change_language(locale):
	TranslationServer.set_locale(locale)
	slides.update_translations()

func _on_SwipeDetector_swiped(direction):
	if direction.x == 1:
		slides.display(slides.DIRECTIONS.NEXT)
	if direction.x == -1:
		slides.display(slides.DIRECTIONS.PREVIOUS)

func _on_TouchControls_slide_change_requested(direction):
	slides.display(direction)

func get_translatable_strings():
	"""
	Returns a dictionary with a list of { translatable_string_uid: string }
	and the version of the project in which the data was generated
	"""
	var data = []
	for node in get_tree().get_nodes_in_group("translate"):
		var src_data = node.get_translation_data()
		var node_uid = slides.get_translation_uid(node)
		for key in src_data:
			var string_uid = node_uid + "_" + key
			data.append({ string_uid: src_data[key] })
	return {
			'data': data,
			'version': ProjectSettings.get_setting("application/config/version"),
		}

func save_as_csv(translation_data):
	"""
	Saves translation data from get_translatable_strings() to
	this scene's folder, as scene_name.csv
	"""
	# FIXME
	var filename: String = translation_data.get('filename')
	assert(filename != null)
	var folder_path = filename.left(filename.rfind("/") + 1)
	var save_path = folder_path + name + ".csv"
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	
	if file:
		file.store_line("Hello, Godot 4!")
		file.close()
	else:
		push_error("Error saving translation data: could not open file %s" % save_path)
		return
	
	file.store_line("id,en")
	var data_list = translation_data['data']
	var csv_list = []
	for dict in data_list:
		for key in dict:
			var as_csv = key + "," +  "\"" + dict[key] + "\""
			csv_list.append(as_csv)
	for line in csv_list:
		file.store_line(line)
	file.close()
