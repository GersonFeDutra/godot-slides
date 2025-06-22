extends Control

signal slide_change_requested(direction)

enum DIRECTIONS {PREVIOUS = -1, NEXT = 1}

func _ready():
	for child in get_children():
		child.touched.connect(_on_touch_button_touched)

func _on_touch_button_touched(button):
	if button == $TouchButtonLeft:
		slide_change_requested.emit(DIRECTIONS.PREVIOUS)
	if button == $TouchButtonRight:
		slide_change_requested.emit(DIRECTIONS.NEXT)
