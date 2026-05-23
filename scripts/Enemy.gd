extends Area3D

@export var move_speed: float = 4.2
@export var touch_damage: int = 1
@export var hit_radius: float = 0.85
@export var max_hits: int = 1

var _main: Node
var _dead := false
var _hits_left: int = 1
var _body: MeshInstance3D
var _body_material: StandardMaterial3D
var _enemy_kind: String = "fast"

func configure(kind: String) -> void:
	_enemy_kind = kind
	if kind == "heavy":
		move_speed = 2.7
		max_hits = 2
		hit_radius = 1.05
		touch_damage = 2
	else:
		move_speed = 7.2
		max_hits = 1
		hit_radius = 0.72
		touch_damage = 1

func _ready() -> void:
	add_to_group("enemies")
	_main = get_tree().current_scene
	monitoring = true
	monitorable = true
	_hits_left = max_hits

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = hit_radius
	shape.shape = sphere
	add_child(shape)

	_body = MeshInstance3D.new()
	_body.name = "Body"
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.58 if _enemy_kind == "heavy" else 0.38
	mesh.height = 1.6 if _enemy_kind == "heavy" else 1.18
	_body.mesh = mesh
	_body_material = _make_material(Color(0.32, 0.16, 0.62) if _enemy_kind == "heavy" else Color(0.85, 0.12, 0.1))
	_body.material_override = _body_material
	add_child(_body)

	var marker := MeshInstance3D.new()
	marker.name = "Marker"
	var marker_mesh := SphereMesh.new()
	marker_mesh.radius = 0.16
	marker_mesh.height = 0.32
	marker.mesh = marker_mesh
	marker.material_override = _make_material(Color(0.2, 0.9, 1.0) if _enemy_kind == "heavy" else Color(1.0, 0.85, 0.12))
	marker.position = Vector3(0, 0.75 if _enemy_kind == "heavy" else 0.58, -0.18)
	add_child(marker)

	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if _dead or _main == null:
		return
	var target: Vector3 = _main.call("get_turret_position")
	var direction := target - global_position
	direction.y = 0
	if direction.length() > 0.01:
		global_position += direction.normalized() * move_speed * delta
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	if global_position.distance_to(target) <= 1.25:
		_touch_turret()

func _on_area_entered(area: Area3D) -> void:
	if _dead:
		return
	if area.is_in_group("projectiles"):
		area.queue_free()
		_take_hit()
	elif area.is_in_group("turret"):
		_touch_turret()

func _take_hit() -> void:
	_hits_left -= 1
	if _hits_left <= 0:
		_die()
	else:
		_flash_damage()

func _flash_damage() -> void:
	if _body_material:
		_body_material.albedo_color = Color(0.95, 0.95, 1.0)
		await get_tree().create_timer(0.08).timeout
		if is_inside_tree() and _body_material:
			_body_material.albedo_color = Color(0.32, 0.16, 0.62)

func _die() -> void:
	_dead = true
	if _main and _main.has_method("add_score"):
		_main.call("add_score", 1)
	queue_free()

func _touch_turret() -> void:
	_dead = true
	if _main and _main.has_method("damage_turret"):
		_main.call("damage_turret", touch_damage)
	queue_free()

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
