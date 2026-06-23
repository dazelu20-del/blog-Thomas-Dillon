extends Area3D

@export var weapon_id := "rifle"

@onready var label: Label3D = $Label3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var _base_position: Vector3

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	label.text = weapon_id.capitalize()
	_setup_color()
	_base_position = global_position

func set_spawn_position(pos: Vector3) -> void:
	global_position = pos
	_base_position = pos

func _setup_color() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = match weapon_id:
		"rifle": Color(0.3, 0.3, 0.35)
		"pistol": Color(0.45, 0.35, 0.2)
		"sniper": Color(0.15, 0.25, 0.15)
		_: Color(0.25, 0.25, 0.25)
	mat.roughness = 1.0
	mesh.material_override = mat

func _process(delta: float) -> void:
	rotate_y(delta * 1.5)
	global_position = _base_position + Vector3(0, sin(Time.get_ticks_msec() * 0.003) * 0.1, 0)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var manager := body.get_node_or_null("WeaponManager")
	if not manager:
		return
	if manager.add_weapon(weapon_id):
		var hud := get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_message("Picked up %s!" % weapon_id.capitalize())
		queue_free()
