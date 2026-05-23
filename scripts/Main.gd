extends Node3D

const EnemyScene := preload("res://scripts/Enemy.gd")

@export var max_health: int = 10
@export var spawn_interval: float = 1.25
@export var spawn_z: float = -35.0
@export var spawn_x_range: float = 22.0
@export_range(0.0, 1.0, 0.05) var fast_enemy_chance: float = 0.65

var health: int
var score: int = 0

var _health_label: Label
var _score_label: Label
var _spawn_timer: Timer
var _turret: Node3D

func _ready() -> void:
	health = max_health
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	_build_world()
	_build_ui()
	_build_spawn_timer()
	_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var mode := Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
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

func get_turret_position() -> Vector3:
	return _turret.global_position

func _build_world() -> void:
	_add_light()
	_add_environment()
	_add_ground()
	_add_turret()
	_add_camera()

func _add_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_energy = 2.2
	add_child(sun)

func _add_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.78, 0.92)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.82, 0.9, 1.0)
	env.ambient_light_energy = 0.75
	world.environment = env
	add_child(world)

func _add_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "Beach"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(70, 75)
	ground.mesh = mesh
	ground.material_override = _make_material(Color(0.78, 0.66, 0.42))
	ground.position = Vector3(0, -0.02, -10)
	add_child(ground)

	var sea := MeshInstance3D.new()
	sea.name = "Sea"
	var sea_mesh := PlaneMesh.new()
	sea_mesh.size = Vector2(70, 28)
	sea.mesh = sea_mesh
	sea.material_override = _make_material(Color(0.12, 0.45, 0.68))
	sea.position = Vector3(0, -0.04, -38)
	add_child(sea)

func _add_turret() -> void:
	_turret = Node3D.new()
	_turret.name = "Turret"
	_turret.set_script(load("res://scripts/Turret.gd"))
	add_child(_turret)

	var hurtbox := Area3D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.add_to_group("turret")
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.35
	shape.shape = sphere
	hurtbox.add_child(shape)
	_turret.add_child(hurtbox)

func _add_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0, 4.3, 6.0)
	camera.rotation_degrees = Vector3(-24, 0, 0)
	camera.fov = 58.0
	camera.current = true
	add_child(camera)

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	panel.position = Vector2(16, 16)
	panel.custom_minimum_size = Vector2(230, 82)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	margin.add_child(rows)

	_health_label = Label.new()
	_health_label.add_theme_font_size_override("font_size", 24)
	rows.add_child(_health_label)

	_score_label = Label.new()
	_score_label.add_theme_font_size_override("font_size", 24)
	rows.add_child(_score_label)

	var hint := Label.new()
	hint.text = "ESC 释放/捕获鼠标"
	hint.position = Vector2(18, 108)
	hint.add_theme_font_size_override("font_size", 16)
	canvas.add_child(hint)

func _build_spawn_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.name = "EnemySpawnTimer"
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.autostart = true
	_spawn_timer.timeout.connect(_spawn_enemy)
	add_child(_spawn_timer)

func _spawn_enemy() -> void:
	if health <= 0:
		return
	var enemy := Area3D.new()
	enemy.name = "Enemy"
	enemy.set_script(EnemyScene)
	if randf() <= fast_enemy_chance:
		enemy.call("configure", "fast")
	else:
		enemy.call("configure", "heavy")
	enemy.position = Vector3(randf_range(-spawn_x_range, spawn_x_range), 0.6, spawn_z + randf_range(-4.0, 4.0))
	add_child(enemy)

func _update_ui() -> void:
	if _health_label:
		_health_label.text = "血量: %d" % health
	if _score_label:
		_score_label.text = "积分: %d" % score

func _game_over() -> void:
	_spawn_timer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_health_label.text = "血量: 0  游戏结束"

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
