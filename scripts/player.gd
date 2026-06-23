extends CharacterBody3D

const MOVE_SPEED := 7.0
const MOUSE_SENSITIVITY := 0.002
const MAX_HEALTH := 100

var health := MAX_HEALTH
var grenade_count := 0
var can_throw_grenade := true
var is_dead := false

@onready var camera: Camera3D = $Camera3D
@onready var weapon_manager: Node = $WeaponManager

var hud: CanvasLayer

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud = get_tree().get_first_node_in_group("hud")

func _unhandled_input(event: InputEvent) -> void:
	if is_dead or get_tree().paused:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		if hud and hud.has_method("is_pause_visible") and hud.is_pause_visible():
			if hud.has_method("hide_pause_menu"):
				hud.hide_pause_menu()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if hud and hud.has_method("show_pause_menu"):
				hud.show_pause_menu(true)

	if event.is_action_pressed("throw_grenade"):
		_try_throw_grenade()

func _physics_process(delta: float) -> void:
	if is_dead or get_tree().paused:
		return

	if not is_on_floor():
		velocity.y -= 20.0 * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED
	move_and_slide()

	if hud:
		hud.update_health(health)
		hud.update_grenades(grenade_count)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health = max(health - amount, 0)
	if hud:
		hud.update_health(health)
	if health <= 0:
		_die()

func heal(amount: int) -> void:
	health = min(health + amount, MAX_HEALTH)

func receive_grenade(count: int = 1) -> void:
	grenade_count += count
	if hud:
		hud.update_grenades(grenade_count)

func _try_throw_grenade() -> void:
	if grenade_count <= 0 or not can_throw_grenade:
		return
	var grenade_scene := preload("res://scenes/grenade.tscn")
	var grenade := grenade_scene.instantiate()
	get_tree().current_scene.add_child(grenade)
	var throw_dir := -camera.global_transform.basis.z.normalized()
	grenade.global_position = camera.global_position + throw_dir * 0.8
	grenade.throw(throw_dir, self)
	grenade_count -= 1
	can_throw_grenade = false
	await get_tree().create_timer(0.5).timeout
	can_throw_grenade = true

func _die() -> void:
	is_dead = true
	GameState.set_died()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func return_to_title() -> void:
	GameState.set_quit()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
