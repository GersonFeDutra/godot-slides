extends CharacterBody2D

signal state_changed
signal direction_changed

enum STATES { IDLE, ATTACK, STAGGER, DIE, DEAD }
var state = null

# MOTION
var input_direction = Vector2()
var look_direction = Vector2(1, 0)
var last_move_direction = Vector2(1, 0)

# STAGGER
var knockback_direction = Vector2(0.0, 0.0)
@export var stagger_knockback: float = 15
const STAGGER_DURATION = 0.4

# WEAPON
var weapon_path = "res://content/demos/attacks/characters/weapon/Sword.tscn"
var weapon = null
var tween: Tween = null


func _ready():
	_change_state(STATES.IDLE)
	$AnimationPlayer.animation_finished.connect(_on_AnimationPlayer_animation_finished)
	$Health.health_changed.connect(_on_Health_health_changed)
	$Health.status_changed.connect(_on_Health_status_changed)

	if not weapon_path:
		return
	var weapon_instance = load(weapon_path).instantiate()
	$WeaponPivot/WeaponSpawn.add_child(weapon_instance)
	weapon = $WeaponPivot/WeaponSpawn.get_child(0)
	weapon.attack_finished.connect(_on_Weapon_attack_finished)
	tween = create_tween()
	tween.stop()


func _change_state(new_state):
	match state:
		STATES.DIE:
			queue_free()
		STATES.ATTACK:
			set_physics_process(true)

	# Initialize the new state
	match new_state:
		STATES.IDLE:
			$AnimationPlayer.play('idle')
		STATES.ATTACK:
			set_physics_process(false)
			if not weapon:
				print("%s tries to attack but has no weapon" % get_name())
				_change_state(STATES.IDLE)
				return

			weapon.attack()
			$AnimationPlayer.play('idle')
		STATES.STAGGER:
			if tween.is_valid() and tween.is_running():
				tween.stop()
			else:
				tween = create_tween()
			tween.tween_property(self, ^'position', position + stagger_knockback * -knockback_direction, STAGGER_DURATION)
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)
			tween.start()
			
			$AnimationPlayer.play('stagger')
		STATES.DIE:
			set_process_input(false)
			set_physics_process(false)
			$CollisionShape2D.disabled = true
			tween.stop()
			$AnimationPlayer.play('die')
	state = new_state
	emit_signal('state_changed', new_state)


func _physics_process(_delta):
	if not input_direction:
		return

	last_move_direction = input_direction
	if input_direction.x in [-1, 1]:
		look_direction.x = input_direction.x
		$BodyPivot.set_scale(Vector2(look_direction.x, 1))


func take_damage(attacker_weapon, amount, effect):
	if is_ancestor_of(attacker_weapon):
		return
	knockback_direction = (attacker_weapon.global_position - global_position).normalized()
	$Health.take_damage(amount, effect)


func _on_Weapon_attack_finished():
	_change_state(STATES.IDLE)


func _on_AnimationPlayer_animation_finished(_name):
	if _name == 'die':
		_change_state(STATES.DEAD)


func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state(STATES.DIE)
	else:
		_change_state(STATES.STAGGER)


func _on_Health_status_changed(new_status):
	match new_status:
		GlobalConstants.STATUS_POISONED:
			$BodyPivot/PoisonBubbles.emitting = true
		_:
			$BodyPivot/PoisonBubbles.emitting = false
