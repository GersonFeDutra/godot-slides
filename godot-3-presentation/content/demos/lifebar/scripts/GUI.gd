extends MarginContainer

@onready var number := $Bars/LifeBar/Count/Background/Number
@onready var bar := $Bars/LifeBar/TextureProgress
@onready var tween: Tween

var animated_health = 0


func _ready():
	if not has_node(^"../Characters/Player"):
		return
	var player_max_health = $"../Characters/Player".max_health
	bar.max_value = player_max_health
	update_health(player_max_health)
	tween = create_tween()
	tween.stop()


func _on_Player_health_changed(player_health):
	update_health(player_health)


func update_health(new_value):
	if tween.is_valid() and tween.is_running():
		tween.stop()
	else:
		tween = create_tween()
	tween.tween_property(self, ^"animated_health", new_value, 0.6)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	
	if not tween.is_active():
		tween.play()


func _process(_delta: float) -> void:
	var round_value = round(animated_health)
	number.text = str(round_value)
	bar.value = round_value


func _on_Player_died():
	var end_color := Color(1.0, 1.0, 1.0, 0.0)
	if tween.is_valid() and tween.is_running():
		tween.stop()
	else:
		tween = create_tween()
	tween.tween_property(self, ^"modulate", end_color, 1.0)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
