extends Node3D

@export var weapon_name := "Shotgun"
@export var pellet_count := 8
@export var spread_degrees := 6.0
@export var damage_per_pellet := 15
@export var max_range := 40.0
@export var fire_rate := 0.8
@export var max_ammo := 8
@export var reload_time := 1.5

var ammo := 8
var can_fire := true
var is_reloading := false
var is_active := false
var owner_player: CharacterBody3D

@onready var muzzle: Marker3D = $Muzzle

var hud: CanvasLayer

func _ready() -> void:
	ammo = max_ammo
	hud = get_tree().get_first_node_in_group("hud")

func set_owner_player(player: CharacterBody3D) -> void:
	owner_player = player

func set_active(active: bool) -> void:
	is_active = active
	visible = active
	if active:
		_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("shoot") and can_fire and not is_reloading:
		_fire()
	if event.is_action_pressed("reload") and not is_reloading and ammo < max_ammo:
		_reload()

func _fire() -> void:
	if ammo <= 0:
		_reload()
		return

	ammo -= 1
	can_fire = false
	_update_hud()

	var space_state := get_world_3d().direct_space_state
	var origin := muzzle.global_position
	var base_dir := -muzzle.global_transform.basis.z.normalized()

	for i in pellet_count:
		var dir := base_dir
		dir = dir.rotated(muzzle.global_transform.basis.x, deg_to_rad(randf_range(-spread_degrees, spread_degrees)))
		dir = dir.rotated(muzzle.global_transform.basis.y, deg_to_rad(randf_range(-spread_degrees, spread_degrees)))
		dir = dir.normalized()
		var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * max_range)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		if owner_player:
			query.exclude = [owner_player.get_rid()]
		var result := space_state.intersect_ray(query)
		if result:
			var collider = result.collider
			if collider and collider.has_method("take_damage"):
				collider.take_damage(damage_per_pellet)

	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func _reload() -> void:
	is_reloading = true
	if hud:
		hud.show_message("Reloading %s..." % weapon_name)
	await get_tree().create_timer(reload_time).timeout
	ammo = max_ammo
	is_reloading = false
	_update_hud()

func _update_hud() -> void:
	if hud and hud.has_method("update_ammo"):
		hud.update_ammo(ammo, max_ammo, weapon_name)
