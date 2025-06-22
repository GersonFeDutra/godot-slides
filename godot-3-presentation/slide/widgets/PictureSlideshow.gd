extends Control

@export_range(0.0, 10.0) var DISPLAY_DURATION: float = 4.0
@export_range(0.0, 1.0) var TRANSITION_DURATION: float = 0.4
@export var COLOR_MODULATE_PAUSED: Color = Color('#d9e2e5')

const COLOR_OPAQUE = Color("#ffffffff")
const COLOR_TRANSPARENT = Color("#00ffffff")

@onready var tween: Tween
@onready var timer = $Timer

var paused = false:
	set = set_paused

var slides = []
var index = 0
var picture_active

func _ready():
	tween = create_tween()
	tween.stop()
	
	for node in get_children():
		if not node is Control:
			continue
		slides.append(node)

	for widget in slides:
		widget.modulate = COLOR_TRANSPARENT
		widget.hide()
	start()
	

# Pause and navigation
func _input(event):
	if event.is_action_pressed('ui_accept'):
		self.paused = not paused

	if event.is_action_pressed('ui_left'):
		display(index - 1, false)
	if event.is_action_pressed('ui_right'):
		display(index + 1, false)

func set_paused(value):
	paused = value
	timer.paused = value
	if paused:
		tween.stop_all()
		modulate = COLOR_MODULATE_PAUSED
	else:
		tween.resume_all()
		modulate = COLOR_OPAQUE

func _on_Timer_timeout():
	display(index + 1)

func display(slide_index, animate=true):
	var picture_previous = picture_active
	index = (slide_index + slides.size()) % slides.size()
	picture_active = slides[index]
	picture_active.show()

	if animate:
		if tween.is_valid() and tween.is_running():
			tween.stop()
		else:
			tween = create_tween()
		tween.tween_property(picture_previous, ^'modulate', COLOR_TRANSPARENT, TRANSITION_DURATION)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(picture_active, ^'modulate', COLOR_OPAQUE, TRANSITION_DURATION)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN)
		tween.play()
		await tween.finished

	picture_previous.modulate = COLOR_TRANSPARENT
	picture_active.modulate = COLOR_OPAQUE
	picture_previous.hide()
	timer.start()

func _on_tree_entered():
	start()

func start():
	index = 0
	if not slides:
		return
	picture_active = slides[index]
	picture_active.modulate = COLOR_OPAQUE
	picture_active.show()
	timer.wait_time = DISPLAY_DURATION
	
	timer.call_deferred(&"start")
