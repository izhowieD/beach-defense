extends Area3D

@export var move_speed: float = 4.2
@export var touch_damage: int = 1
@export var max_hits: int = 1
@export var score_value: int = 1
@export var contact_radius: float = 1.25

var _level: Node
var _game: Node
var _dead: bool = false
var _hits_left: int = 1
@onready var _body: MeshInstance3D = get_node_or_null("enemy_mesh")

func _ready() -> void:
	add_to_group("enemies")
	_level = _find_level_controller()
	_game = get_tree().get_first_node_in_group("game")
	if _game == null:
		_game = get_tree().current_scene
	monitoring = true
	monitorable = true
	_hits_left = max_hits
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if _dead or _level == null:
		return
	var target: Vector3 = _get_target_position()
	var direction: Vector3 = target - global_position
	direction.y = 0
	if direction.length() > 0.01:
		global_position += direction.normalized() * move_speed * delta
		global_position = _clamp_to_play_area(global_position)
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	if global_position.distance_to(target) <= contact_radius:
		_touch_turret()

func _get_target_position() -> Vector3:
	if _level and _level.has_method("get_enemy_target_position"):
		return _level.call("get_enemy_target_position") as Vector3
	if _level and _level.has_method("get_turret_position"):
		var fallback_target: Vector3 = _level.call("get_turret_position")
		fallback_target.y = global_position.y
		return fallback_target
	return global_position

func _clamp_to_play_area(position: Vector3) -> Vector3:
	if _level == null or not _level.has_method("get_enemy_play_area"):
		return position
	var play_area: Dictionary = _level.call("get_enemy_play_area") as Dictionary
	var origin: Vector3 = play_area.get("origin", Vector3.ZERO) as Vector3
	var max_angle: float = deg_to_rad(float(play_area.get("max_angle_degrees", 60.0)))
	var max_distance: float = float(play_area.get("max_distance", 56.0))
	var offset: Vector3 = position - origin
	offset.y = 0
	var distance: float = minf(offset.length(), max_distance)
	if distance <= 0.01:
		return position
	var angle: float = clampf(atan2(offset.x, -offset.z), -max_angle, max_angle)
	return Vector3(
		origin.x + sin(angle) * distance,
		position.y,
		origin.z - cos(angle) * distance
	)

func _on_area_entered(area: Area3D) -> void:
	if _dead:
		return
	if area.is_in_group("projectiles"):
		var damage: int = 1
		if area.has_method("get_damage"):
			damage = area.call("get_damage")
		area.queue_free()
		_take_hit(damage)
	elif area.is_in_group("turret"):
		_touch_turret()

func _take_hit(damage: int) -> void:
	_hits_left -= damage
	if _hits_left <= 0:
		_die()
	else:
		_flash_damage()

func _flash_damage() -> void:
	if _body == null or _body.material_override == null:
		return
	var material: StandardMaterial3D = _body.material_override as StandardMaterial3D
	if material == null:
		return
	var original_color: Color = material.albedo_color
	material.albedo_color = Color(0.95, 0.95, 1.0)
	await get_tree().create_timer(0.08).timeout
	if is_inside_tree() and material:
		material.albedo_color = original_color

func _die() -> void:
	_dead = true
	if _game and _game.has_method("add_score"):
		_game.call("add_score", score_value)
	queue_free()

func _touch_turret() -> void:
	_dead = true
	if _game and _game.has_method("damage_turret"):
		_game.call("damage_turret", touch_damage)
	queue_free()

func _find_level_controller() -> Node:
	var node: Node = get_parent()
	while node:
		if node.has_method("get_enemy_target_position") and node.has_method("get_enemy_play_area"):
			return node
		node = node.get_parent()
	return get_tree().get_first_node_in_group("level")
