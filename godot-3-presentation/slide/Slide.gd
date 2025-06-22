extends Control

@onready var player = $AnimationPlayer

func play(anim_name):
	player.play(anim_name)
	await player.animation_finished
