extends "../character.gd"

func _input(event):
	if event.is_action_pressed("attack") and state != STATES.ATTACK:
		_change_state(STATES.ATTACK)

func _physics_process(_delta: float) -> void:
	input_direction = Vector2()
	input_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))

	if input_direction and input_direction != last_move_direction:
		emit_signal('direction_changed', input_direction)
