extends Node3D

const PICKUP_SCENE := preload("res://scenes/weapon_pickup.tscn")

const SPAWN_DATA := [
	{"id": "rifle", "pos": Vector3(-20, 0.8, -15)},
	{"id": "pistol", "pos": Vector3(25, 0.8, -20)},
	{"id": "sniper", "pos": Vector3(-30, 0.8, 30)},
	{"id": "rifle", "pos": Vector3(35, 0.8, 10)},
	{"id": "pistol", "pos": Vector3(-10, 0.8, 35)},
	{"id": "sniper", "pos": Vector3(15, 0.8, -35)},
	{"id": "pistol", "pos": Vector3(-35, 0.8, -30)},
	{"id": "rifle", "pos": Vector3(40, 0.8, -5)},
]

func _ready() -> void:
	for data in SPAWN_DATA:
		var pickup: Area3D = PICKUP_SCENE.instantiate()
		pickup.weapon_id = data.id
		add_child(pickup)
		if pickup.has_method("set_spawn_position"):
			pickup.set_spawn_position(data.pos)
		else:
			pickup.global_position = data.pos
