extends RigidBody3D

const FUSE_TIME := 3.0
const EXPLOSION_RADIUS := 8.0
const EXPLOSION_DAMAGE := 80
const THROW_FORCE := 18.0

var thrower: Node3D
var has_exploded := false

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $FuseTimer

func _ready() -> void:
	timer.wait_time = FUSE_TIME
	timer.one_shot = true
	timer.timeout.connect(_explode)
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func throw(direction: Vector3, owner_node: Node3D) -> void:
	thrower = owner_node
	linear_velocity = direction * THROW_FORCE + Vector3.UP * 4.0
	timer.start()

func _on_body_entered(body: Node) -> void:
	if body == thrower:
		return
	if body is CharacterBody3D or body is StaticBody3D:
		_explode()

func _explode() -> void:
	if has_exploded:
		return
	has_exploded = true

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = EXPLOSION_RADIUS
	query.shape = sphere
	query.transform = Transform3D(Basis(), global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results := space_state.intersect_shape(query, 64)
	for result in results:
		var collider = result.collider
		if collider and collider != thrower and collider.has_method("take_damage"):
			collider.take_damage(EXPLOSION_DAMAGE)

	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_message("BOOM!")

	queue_free()
