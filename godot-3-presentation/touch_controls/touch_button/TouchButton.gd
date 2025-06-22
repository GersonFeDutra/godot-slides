extends Button

signal touched(button)

const COLOR_TRANSPARENT = Color("#00ffffff")
const COLOR_OPAQUE = Color("#ffffffff")

const TRANSITION_DURATION = 0.4

var tween: Tween = null

func _ready():
	modulate = COLOR_TRANSPARENT
	tween = create_tween()
	tween.stop()

func _on_mouse_entered():
	if tween.is_valid() and tween.is_running():
		tween.stop()
	else:
		tween = create_tween()
	tween.tween_property(self, ^'modulate', COLOR_OPAQUE, TRANSITION_DURATION)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.play()

func _on_mouse_exited():
	if tween.is_valid() and tween.is_running():
		tween.stop()
	else:
		tween = create_tween()
	tween.tween_property(self, ^'modulate', COLOR_TRANSPARENT, TRANSITION_DURATION)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.play()

func _on_pressed():
	touched.emit(self)
	get_viewport().set_input_as_handled()
