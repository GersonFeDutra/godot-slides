extends TextureRect

var path = "":
	set = set_path

const main_folder = "res://content/power_pitch/img/"
const alternate_folder = "res://content/_old_presentation/img/"

func set_path(string):
	path = string
	visible = path != ""
	if path == "":
		return

	var abspath = path if path.begins_with("res://") else find_abs_path(path)
	var image = ImageTexture.new()
	image.load(abspath)
	texture = image


func find_abs_path(file_name):
	
	if FileAccess.file_exists(main_folder + file_name):
		return main_folder + file_name
	else:
		return alternate_folder + file_name
