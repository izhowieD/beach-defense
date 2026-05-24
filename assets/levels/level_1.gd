extends Node3D

@export var wall_height: float = 24.0
@export var wall_front_z: float = -3.0
@export var spawn_max_distance: float = 56.0
@export var spawn_angle_degrees: float = 60.0
@export var battlefield_scene: PackedScene = preload("res://assets/levels/outside_battlefield.tscn")
@export var wall_scene: PackedScene = preload("res://assets/levels/castle_wall.tscn")
@export var turret_scene: PackedScene = preload("res://assets/turrets/turret_player.tscn")
@export var fast_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_fast.tscn")
@export var heavy_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_heavy.tscn")

@export_group("Wave 1")
@export var wave_1_enabled: bool = true
@export var wave_1_time: float = 1.0
@export_enum("Left", "Center", "Right") var wave_1_position: String = "Center"
@export var wave_1_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_fast.tscn")
@export_range(1, 50, 1) var wave_1_count: int = 4
@export var wave_1_spawn_gap: float = 0.45

@export_group("Wave 2")
@export var wave_2_enabled: bool = true
@export var wave_2_time: float = 7.0
@export_enum("Left", "Center", "Right") var wave_2_position: String = "Left"
@export var wave_2_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_fast.tscn")
@export_range(1, 50, 1) var wave_2_count: int = 5
@export var wave_2_spawn_gap: float = 0.4

@export_group("Wave 3")
@export var wave_3_enabled: bool = true
@export var wave_3_time: float = 13.0
@export_enum("Left", "Center", "Right") var wave_3_position: String = "Right"
@export var wave_3_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_heavy.tscn")
@export_range(1, 50, 1) var wave_3_count: int = 3
@export var wave_3_spawn_gap: float = 0.75

@export_group("Wave 4")
@export var wave_4_enabled: bool = true
@export var wave_4_time: float = 20.0
@export_enum("Left", "Center", "Right") var wave_4_position: String = "Center"
@export var wave_4_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_fast.tscn")
@export_range(1, 50, 1) var wave_4_count: int = 8
@export var wave_4_spawn_gap: float = 0.32

@export_group("Wave 5")
@export var wave_5_enabled: bool = true
@export var wave_5_time: float = 30.0
@export_enum("Left", "Center", "Right") var wave_5_position: String = "Left"
@export var wave_5_enemy_scene: PackedScene = preload("res://assets/enemies/enemy_heavy.tscn")
@export_range(1, 50, 1) var wave_5_count: int = 5
@export var wave_5_spawn_gap: float = 0.65

var _wave_timers: Array[Timer] = []
var _level_stopped: bool = false
var _turret: Node3D

func _ready() -> void:
	add_to_group("level")
	_build_world()
	_schedule_waves()

func stop_level() -> void:
	_level_stopped = true
	for timer: Timer in _wave_timers:
		if timer:
			timer.stop()

func get_turret_position() -> Vector3:
	if _turret:
		return _turret.global_position
	return global_position

func get_enemy_target_position() -> Vector3:
	return Vector3(0, 0.6, wall_front_z)

func get_enemy_play_area() -> Dictionary:
	return {
		"origin": Vector3(0, 0.6, wall_front_z),
		"max_angle_degrees": spawn_angle_degrees,
		"max_distance": spawn_max_distance
	}

func _build_world() -> void:
	_add_light()
	_add_environment()
	_add_ground()
	_add_wall()
	_add_turret()

func _add_light() -> void:
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_energy = 2.2
	add_child(sun)

func _add_environment() -> void:
	var world: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.78, 0.92)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.82, 0.9, 1.0)
	env.ambient_light_energy = 0.75
	world.environment = env
	add_child(world)

func _add_ground() -> void:
	if battlefield_scene == null:
		return
	var ground: Node3D = battlefield_scene.instantiate() as Node3D
	if ground == null:
		return
	ground.name = "OutsideBattlefield"
	ground.set("center_offset_z", wall_front_z)
	ground.set("angle_degrees", spawn_angle_degrees * 2.2)
	ground.set("radius", spawn_max_distance + 30.0)
	add_child(ground)

func _add_wall() -> void:
	if wall_scene == null:
		return
	var wall: Node3D = wall_scene.instantiate() as Node3D
	if wall == null:
		return
	wall.name = "CastleWall"
	add_child(wall)

func _add_turret() -> void:
	if turret_scene:
		_turret = turret_scene.instantiate() as Node3D
	else:
		_turret = Node3D.new()
		_turret.set_script(load("res://scripts/Turret.gd"))
	_turret.name = "Turret"
	_turret.position = Vector3(0, wall_height + 0.05, wall_front_z + 1.4)
	add_child(_turret)

func _schedule_waves() -> void:
	_schedule_wave(wave_1_enabled, wave_1_time, wave_1_position, wave_1_enemy_scene, wave_1_count, wave_1_spawn_gap)
	_schedule_wave(wave_2_enabled, wave_2_time, wave_2_position, wave_2_enemy_scene, wave_2_count, wave_2_spawn_gap)
	_schedule_wave(wave_3_enabled, wave_3_time, wave_3_position, wave_3_enemy_scene, wave_3_count, wave_3_spawn_gap)
	_schedule_wave(wave_4_enabled, wave_4_time, wave_4_position, wave_4_enemy_scene, wave_4_count, wave_4_spawn_gap)
	_schedule_wave(wave_5_enabled, wave_5_time, wave_5_position, wave_5_enemy_scene, wave_5_count, wave_5_spawn_gap)

func _schedule_wave(enabled: bool, start_time: float, lane: String, enemy_scene: PackedScene, count: int, spawn_gap: float) -> void:
	if not enabled or enemy_scene == null or count <= 0:
		return
	var timer: Timer = Timer.new()
	timer.name = "WaveTimer_%s_%s" % [lane, str(_wave_timers.size() + 1)]
	timer.one_shot = true
	timer.wait_time = maxf(start_time, 0.0)
	timer.timeout.connect(_spawn_wave.bind(lane, enemy_scene, count, spawn_gap))
	add_child(timer)
	_wave_timers.append(timer)
	timer.start()

func _spawn_wave(lane: String, enemy_scene: PackedScene, count: int, spawn_gap: float) -> void:
	if _level_stopped:
		return
	for index: int in range(count):
		if _level_stopped or not _is_game_active():
			return
		_spawn_enemy(enemy_scene, lane, index)
		if index < count - 1:
			await get_tree().create_timer(maxf(spawn_gap, 0.0)).timeout

func _spawn_enemy(scene: PackedScene, lane: String, index: int) -> void:
	var game: Node = get_tree().get_first_node_in_group("game")
	if game and game.has_method("is_game_active") and not bool(game.call("is_game_active")):
		return

	if scene == null:
		return
	var enemy: Node3D = scene.instantiate() as Node3D
	if enemy == null:
		return
	enemy.position = _get_spawn_position_at_far_edge(lane, index)
	add_child(enemy)

func _get_spawn_position_at_far_edge(lane: String, index: int) -> Vector3:
	var base_angle: float = deg_to_rad(_get_lane_angle_degrees(lane))
	var spread_offset: float = float((index % 5) - 2) * 1.2
	var angle: float = base_angle + deg_to_rad(spread_offset)
	return Vector3(
		sin(angle) * spawn_max_distance,
		0.6,
		wall_front_z - cos(angle) * spawn_max_distance
	)

func _get_lane_angle_degrees(lane: String) -> float:
	if lane == "Left":
		return -spawn_angle_degrees
	if lane == "Right":
		return spawn_angle_degrees
	return 0.0

func _is_game_active() -> bool:
	var game: Node = get_tree().get_first_node_in_group("game")
	if game and game.has_method("is_game_active"):
		return bool(game.call("is_game_active"))
	return true
