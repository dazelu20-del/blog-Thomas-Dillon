extends CanvasLayer

var _health_label: Label
var _ammo_label: Label
var _grenade_label: Label
var _zombie_label: Label
var _message_label: Label
var _dialogue_panel: PanelContainer
var _dialogue_label: Label
var _game_over_panel: PanelContainer
var _message_timer: Timer
var _pause_panel: PanelContainer

func _ready() -> void:
	add_to_group("hud")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cache_nodes()
	_dialogue_panel.visible = false
	_game_over_panel.visible = false
	if _pause_panel:
		_pause_panel.visible = false
	_message_label.text = ""
	_message_timer.timeout.connect(_clear_message)
	_connect_pause_buttons()

func _cache_nodes() -> void:
	_health_label = get_node_or_null("MarginContainer/VBox/HealthLabel")
	_ammo_label = get_node_or_null("MarginContainer/VBox/AmmoLabel")
	_grenade_label = get_node_or_null("MarginContainer/VBox/GrenadeLabel")
	_zombie_label = get_node_or_null("MarginContainer/VBox/ZombieLabel")
	_message_label = get_node_or_null("MarginContainer/VBox/MessageLabel")
	_dialogue_panel = get_node_or_null("DialoguePanel")
	_dialogue_label = get_node_or_null("DialoguePanel/Margin/DialogueLabel")
	_game_over_panel = get_node_or_null("GameOverPanel")
	_message_timer = get_node_or_null("MessageTimer")
	_pause_panel = get_node_or_null("PausePanel")

func _connect_pause_buttons() -> void:
	var resume_btn := get_node_or_null("PausePanel/Margin/VBox/ResumeButton")
	var title_btn := get_node_or_null("PausePanel/Margin/VBox/TitleButton")
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	if title_btn:
		title_btn.pressed.connect(_on_title_pressed)

func is_pause_visible() -> bool:
	return _pause_panel and _pause_panel.visible

func show_pause_menu(show_menu: bool) -> void:
	if not _pause_panel:
		call_deferred("show_pause_menu", show_menu)
		return
	_pause_panel.visible = show_menu
	get_tree().paused = show_menu

func hide_pause_menu() -> void:
	show_pause_menu(false)

func _on_resume_pressed() -> void:
	hide_pause_menu()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_title_pressed() -> void:
	get_tree().paused = false
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("return_to_title"):
		player.return_to_title()
	else:
		GameState.set_quit()
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func update_health(value: int) -> void:
	if not _health_label:
		call_deferred("update_health", value)
		return
	_health_label.text = "Health: %d" % value

func update_ammo(current: int, maximum: int, weapon_name: String = "Shotgun") -> void:
	if not _ammo_label:
		call_deferred("update_ammo", current, maximum, weapon_name)
		return
	_ammo_label.text = "%s: %d / %d" % [weapon_name, current, maximum]

func update_grenades(count: int) -> void:
	if not _grenade_label:
		call_deferred("update_grenades", count)
		return
	_grenade_label.text = "Grenades: %d" % count

func update_zombie_count(count: int) -> void:
	if not _zombie_label:
		call_deferred("update_zombie_count", count)
		return
	_zombie_label.text = "Zombies: %d" % count

func show_message(text: String) -> void:
	if not _message_label:
		call_deferred("show_message", text)
		return
	_message_label.text = text
	_message_timer.start(2.5)

func show_dialogue(text: String) -> void:
	if not _dialogue_label:
		call_deferred("show_dialogue", text)
		return
	_show_dialogue(text)

func show_game_over() -> void:
	if not _game_over_panel:
		call_deferred("show_game_over")
		return
	_game_over_panel.visible = true

func _show_dialogue(text: String) -> void:
	_dialogue_label.text = text
	_dialogue_panel.visible = true
	await get_tree().create_timer(4.0).timeout
	_dialogue_panel.visible = false

func _clear_message() -> void:
	if _message_label:
		_message_label.text = ""
