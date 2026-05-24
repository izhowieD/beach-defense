extends Node3D

@export var projectile_scene: PackedScene = preload("res://assets/projectiles/projectile_shell.tscn")
@export var mouse_sensitivity: float = 0.003
@export var max_yaw_degrees: float = 60.0
@export var min_pitch_degrees: float = -90.0
@export var max_pitch_degrees: float = 0.0
@export var fire_interval: float = 0.28

var _yaw: float = 0.0
var _pitch: float = 0.0
var _barrel_pivot: Node3D
var _camera_pitch_pivot: Node3D
var _muzzle: Node3D
var _fire_timer: Timer

func _ready() -> void:
	_setup_model_refs()
	_build_fire_timer()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var yaw_limit: float = deg_to_rad(max_yaw_degrees)
		_yaw = clamp(_yaw - event.relative.x * mouse_sensitivity, -yaw_limit, yaw_limit)
		_pitch = clamp(
			_pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)
		rotation.y = _yaw
		_barrel_pivot.rotation.x = _pitch
		if _camera_pitch_pivot:
			_camera_pitch_pivot.rotation.x = _pitch

func _setup_model_refs() -> void:
	_barrel_pivot = get_node_or_null("BarrelPivot")
	_camera_pitch_pivot = get_node_or_null("CameraPitchPivot")
	if _barrel_pivot:
		_muzzle = _barrel_pivot.get_node_or_null("Muzzle")
	if _barrel_pivot == null or _muzzle == null:
		_build_model()
	if _camera_pitch_pivot == null:
		_build_camera()

func _build_model() -> void:
	var base: MeshInstance3D = MeshInstance3D.new()
	base.name = "Base"
	var base_mesh: CylinderMesh = CylinderMesh.new()
	base_mesh.top_radius = 1.25
	base_mesh.bottom_radius = 1.55
	base_mesh.height = 0.7
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.18, 0.22, 0.24))
	base.position.y = 0.35
	add_child(base)

	var head: MeshInstance3D = MeshInstance3D.new()
	head.name = "RotatingHead"
	var head_mesh: BoxMesh = BoxMesh.new()
	head_mesh.size = Vector3(1.9, 1.2, 1.5)
	head.mesh = head_mesh
	head.material_override = _make_material(Color(0.33, 0.37, 0.38))
	head.position.y = 1.2
	add_child(head)

	_barrel_pivot = Node3D.new()
	_barrel_pivot.name = "BarrelPivot"
	_barrel_pivot.position = Vector3(0, 1.35, -0.75)
	add_child(_barrel_pivot)

	var barrel: MeshInstance3D = MeshInstance3D.new()
	barrel.name = "Barrel"
	var barrel_mesh: CylinderMesh = CylinderMesh.new()
	barrel_mesh.top_radius = 0.18
	barrel_mesh.bottom_radius = 0.27
	barrel_mesh.height = 4.2
	barrel.mesh = barrel_mesh
	barrel.material_override = _make_material(Color(0.08, 0.09, 0.09))
	barrel.rotation_degrees.x = 90
	barrel.position = Vector3(0, 0, -2.1)
	_barrel_pivot.add_child(barrel)

	_muzzle = Node3D.new()
	_muzzle.name = "Muzzle"
	_muzzle.position = Vector3(0, 0, -4.35)
	_barrel_pivot.add_child(_muzzle)

func _build_camera() -> void:
	_camera_pitch_pivot = Node3D.new()
	_camera_pitch_pivot.name = "CameraPitchPivot"
	_camera_pitch_pivot.position = Vector3(0, 1.35, -0.75)
	add_child(_camera_pitch_pivot)

	var camera: Camera3D = Camera3D.new()
	camera.name = "AimCamera"
	camera.position = Vector3(0, 2.0, 6.2)
	camera.rotation_degrees = Vector3(-6, 0, 0)
	camera.fov = 68.0
	camera.current = true
	_camera_pitch_pivot.add_child(camera)

func _build_fire_timer() -> void:
	_fire_timer = Timer.new()
	_fire_timer.name = "FireTimer"
	_fire_timer.wait_time = fire_interval
	_fire_timer.autostart = true
	_fire_timer.timeout.connect(_fire)
	add_child(_fire_timer)

func _fire() -> void:
	if projectile_scene == null:
		return
	var projectile: Area3D = projectile_scene.instantiate() as Area3D
	if projectile == null:
		return
	projectile.global_transform = _muzzle.global_transform
	get_tree().current_scene.add_child(projectile)
	projectile.call("launch", -_muzzle.global_transform.basis.z)

func _make_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	return material
