extends Node3D

const ZOMBIE_COUNT := 100
const RESPAWN_DELAY := 2.0
const SPAWN_RADIUS := 45.0

@export var zombie_scene: PackedScene

var active_zombies: Array[CharacterBody3D] = []
var pending_respawns := 0

func _ready() -> void:
	if not zombie_scene:
		zombie_scene = preload("res://scenes/zombie.tscn")
	for i in ZOMBIE_COUNT:
		_spawn_zombie(_random_spawn_position())
		if i % 10 == 0:
			await get_tree().process_frame

func _spawn_zombie(position: Vector3) -> void:
	var zombie: CharacterBody3D = zombie_scene.instantiate()
	add_child(zombie)
	zombie.global_position = position
	zombie.died.connect(_on_zombie_died)
	active_zombies.append(zombie)

func _on_zombie_died(zombie: CharacterBody3D) -> void:
	active_zombies.erase(zombie)
	pending_respawns += 1
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	pending_respawns -= 1
	_spawn_zombie(_random_spawn_position())
	_update_hud()

func _random_spawn_position() -> Vector3:
	var angle := randf() * TAU
	var dist := randf_range(15.0, SPAWN_RADIUS)
	var pos := global_position + Vector3(cos(angle) * dist, 1.0, sin(angle) * dist)
	return pos

func _update_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_zombie_count(active_zombies.size())

func _process(_delta: float) -> void:
	_update_hud()
