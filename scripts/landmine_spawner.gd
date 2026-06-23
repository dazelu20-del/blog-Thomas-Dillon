extends Node3D

const MINE_COUNT := 25
const ARENA_HALF_SIZE := 48.0
const SAFE_RADIUS := 12.0

@export var landmine_scene: PackedScene

func _ready() -> void:
	if not landmine_scene:
		landmine_scene = preload("res://scenes/landmine.tscn")
	var player_spawn := Vector3.ZERO
	var npc_spawn := Vector3(8, 0, 8)
	for i in MINE_COUNT:
		var pos := _random_position(player_spawn, npc_spawn)
		var mine := landmine_scene.instantiate()
		add_child(mine)
		mine.global_position = pos

func _random_position(player_spawn: Vector3, npc_spawn: Vector3) -> Vector3:
	for attempt in 20:
		var x := randf_range(-ARENA_HALF_SIZE, ARENA_HALF_SIZE)
		var z := randf_range(-ARENA_HALF_SIZE, ARENA_HALF_SIZE)
		var pos := Vector3(x, 0.15, z)
		if pos.distance_to(player_spawn) < SAFE_RADIUS:
			continue
		if pos.distance_to(npc_spawn) < SAFE_RADIUS:
			continue
		return pos
	return Vector3(randf_range(-30, 30), 0.15, randf_range(-30, 30))
