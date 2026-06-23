extends Area3D

const EXPLOSION_DAMAGE := 60
const EXPLOSION_RADIUS := 5.0

var armed := true

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node3D) -> void:
	if armed and (body.is_in_group("player") or body.is_in_group("zombies")):
		_detonate(body)

func _on_area_entered(area: Area3D) -> void:
	if armed and area.get_parent() and area.get_parent().is_in_group("zombies"):
		_detonate(area.get_parent())

func _detonate(victim: Node) -> void:
	if not armed:
		return
	armed = false

	if victim and victim.has_method("take_damage"):
		victim.take_damage(EXPLOSION_DAMAGE)

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = EXPLOSION_RADIUS
	query.shape = sphere
	query.transform = Transform3D(Basis(), global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results := space_state.intersect_shape(query, 32)
	for result in results:
		var collider = result.collider
		if collider and collider != victim and collider.has_method("take_damage"):
			collider.take_damage(EXPLOSION_DAMAGE)

	if mesh:
		mesh.visible = false
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("Landmine!")

	await get_tree().create_timer(0.5).timeout
	queue_free()
