extends Control

@onready var title_label: Label = $CenterContainer/VBox/TitleLabel
@onready var status_label: Label = $CenterContainer/VBox/StatusLabel
@onready var action_button: Button = $CenterContainer/VBox/ActionButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_ui()
	action_button.pressed.connect(_on_action_pressed)

func _update_ui() -> void:
	match GameState.return_reason:
		GameState.ReturnReason.DIED:
			status_label.text = "You were overrun by zombies!"
			action_button.text = "Respawn"
		GameState.ReturnReason.QUIT:
			status_label.text = "You left the battlefield."
			action_button.text = "Respawn"
		_:
			status_label.text = "Survive the zombie outbreak."
			action_button.text = "Play"

func _on_action_pressed() -> void:
	GameState.set_fresh()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
