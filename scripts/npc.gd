extends StaticBody3D

const INTERACT_RANGE := 4.0
const DIALOGUE := "Hello, the zombie outbreak has spread. Please take this."

var player_in_range := false
var has_given_grenade := false

@onready var interact_area: Area3D = $InteractArea
@onready var label: Label3D = $Label3D

func _ready() -> void:
	add_to_group("npc")
	label.text = "Steve"
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range and not has_given_grenade:
		_give_grenade()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if not has_given_grenade:
			label.text = "Press E to talk"

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if not has_given_grenade:
			label.text = "Steve"

func _give_grenade() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	has_given_grenade = true
	label.text = "Good luck!"
	if player.has_method("receive_grenade"):
		player.receive_grenade(3)
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_dialogue(DIALOGUE)
		hud.show_message("Received 3 grenades! Press G to throw.")
