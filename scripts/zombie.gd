extends CharacterBody3D

signal died(zombie: CharacterBody3D)

const MOVE_SPEED := 3.5
const ATTACK_DAMAGE := 10
const ATTACK_RANGE := 2.0
const ATTACK_COOLDOWN := 1.0
const MAX_HEALTH := 50

var health := MAX_HEALTH
var target: Node3D
var can_attack := true

func _ready() -> void:
	add_to_group("zombies")
	health = MAX_HEALTH
	_find_target()

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_find_target()
		return

	if not is_on_floor():
		velocity.y -= 20.0 * delta

	var to_target := target.global_position - global_position
	to_target.y = 0.0
	var distance := to_target.length()

	if distance > ATTACK_RANGE:
		velocity.x = to_target.normalized().x * MOVE_SPEED
		velocity.z = to_target.normalized().z * MOVE_SPEED
		if distance > 0.1:
			look_at(global_position + to_target.normalized(), Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if can_attack:
			_attack()

	move_and_slide()

func _find_target() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_die()

func _attack() -> void:
	can_attack = false
	if target and target.has_method("take_damage"):
		target.take_damage(ATTACK_DAMAGE)
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true

func _die() -> void:
	died.emit(self)
	queue_free()

func reset_at(position: Vector3) -> void:
	global_position = position
	health = MAX_HEALTH
	_find_target()
