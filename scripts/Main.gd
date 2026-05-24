extends Node3D

@export var max_health: int = 10
@export var starting_level_scene: PackedScene = preload("res://assets/levels/level_1.tscn")

@export_group("Level Quick Settings")
@export var wall_height: float = 24.0
@export var wall_front_z: float = -3.0
@export var spawn_max_distance: float = 56.0
@export var spawn_angle_degrees: float = 60.0

var health: int
var score: int = 0

var _health_label: Label
var _score_label: Label
var _current_level: Node3D

func _enter_tree() -> void:
	_current_level = get_node_or_null("Level1") as Node3D
	_apply_level_quick_settings()

func _ready() -> void:
	add_to_group("game")
	health = max_health
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	_get_or_load_starting_level()
	_apply_level_quick_settings()
	_build_ui()
	_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var mode: int = Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(mode)

func add_score(points: int = 1) -> void:
	score += points
	_update_ui()

func damage_turret(amount: int = 1) -> void:
	if health <= 0:
		return
	health = max(health - amount, 0)
	_update_ui()
	if health == 0:
		_game_over()

func is_game_active() -> bool:
	return health > 0

func _get_or_load_starting_level() -> void:
	_current_level = get_node_or_null("Level1") as Node3D
	if _current_level:
		return
	if starting_level_scene == null:
		return
	_current_level = starting_level_scene.instantiate() as Node3D
	if _current_level == null:
		return
	_current_level.name = "CurrentLevel"
	_apply_level_quick_settings()
	add_child(_current_level)

func _apply_level_quick_settings() -> void:
	if _current_level == null:
		return
	_current_level.set("wall_height", wall_height)
	_current_level.set("wall_front_z", wall_front_z)
	_current_level.set("spawn_max_distance", spawn_max_distance)
	_current_level.set("spawn_angle_degrees", spawn_angle_degrees)

func _build_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "StatusPanel"
	panel.position = Vector2(16, 16)
	panel.custom_minimum_size = Vector2(230, 82)
	canvas.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var rows: VBoxContainer = VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	margin.add_child(rows)

	_health_label = Label.new()
	_health_label.add_theme_font_size_override("font_size", 24)
	rows.add_child(_health_label)

	_score_label = Label.new()
	_score_label.add_theme_font_size_override("font_size", 24)
	rows.add_child(_score_label)

	var hint: Label = Label.new()
	hint.text = "ESC 释放/捕获鼠标"
	hint.position = Vector2(18, 108)
	hint.add_theme_font_size_override("font_size", 16)
	canvas.add_child(hint)

func _update_ui() -> void:
	if _health_label:
		_health_label.text = "血量: %d" % health
	if _score_label:
		_score_label.text = "积分: %d" % score

func _game_over() -> void:
	if _current_level and _current_level.has_method("stop_level"):
		_current_level.call("stop_level")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_health_label.text = "血量: 0  游戏结束"
