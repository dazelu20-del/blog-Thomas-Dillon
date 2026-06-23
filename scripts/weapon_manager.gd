extends Node

const WEAPON_SCENES := {
	"shotgun": "res://scenes/weapons/shotgun.tscn",
	"rifle": "res://scenes/weapons/rifle.tscn",
	"pistol": "res://scenes/weapons/pistol.tscn",
	"sniper": "res://scenes/weapons/sniper.tscn",
}

var weapons: Array[Node3D] = []
var current_index := 0

@onready var player: CharacterBody3D = get_parent()
@onready var camera: Camera3D = player.get_node("Camera3D")

func _ready() -> void:
	add_weapon("shotgun")

func _unhandled_input(event: InputEvent) -> void:
	if weapons.size() <= 1:
		return
	if event.is_action_pressed("weapon_next"):
		_switch_weapon(1)
	elif event.is_action_pressed("weapon_prev"):
		_switch_weapon(-1)

func add_weapon(weapon_id: String) -> bool:
	if not WEAPON_SCENES.has(weapon_id):
		return false
	for w in weapons:
		if _weapon_id(w) == weapon_id:
			_select_weapon(w)
			return false
	var scene: PackedScene = load(WEAPON_SCENES[weapon_id])
	var weapon: Node3D = scene.instantiate()
	camera.add_child(weapon)
	if weapon.has_method("set_owner_player"):
		weapon.set_owner_player(player)
	weapons.append(weapon)
	_select_weapon(weapon)
	return true

func add_weapon_from_scene(scene: PackedScene) -> bool:
	if not scene:
		return false
	var temp: Node3D = scene.instantiate()
	var id: String = _weapon_id(temp)
	temp.queue_free()
	return add_weapon(id)

func _weapon_id(weapon: Node) -> String:
	return String(weapon.get("weapon_name")).to_lower()

func _switch_weapon(direction: int) -> void:
	if weapons.is_empty():
		return
	current_index = posmod(current_index + direction, weapons.size())
	_apply_active_weapon()

func _select_weapon(weapon: Node3D) -> void:
	current_index = weapons.find(weapon)
	if current_index < 0:
		current_index = weapons.size() - 1
	_apply_active_weapon()

func _apply_active_weapon() -> void:
	for i in weapons.size():
		var active := i == current_index
		if weapons[i].has_method("set_active"):
			weapons[i].set_active(active)
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and weapons.size() > 0:
		hud.show_message("Equipped: %s" % String(weapons[current_index].get("weapon_name")))
