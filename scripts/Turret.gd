extends Node3D

const ProjectileScene := preload("res://scripts/Projectile.gd")

@export var mouse_sensitivity: float = 0.003
@export var max_turn_degrees: float = 60.0
@export var fire_interval: float = 0.28
@export var projectile_speed: float = 34.0

var _yaw: float = 0.0
var _pitch: float = 0.0
var _barrel_pivot: Node3D
var _muzzle: Node3D
var _fire_timer: Timer

func _ready() -> void:
	_build_model()
	_build_fire_timer()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var limit := deg_to_rad(max_turn_degrees)
		_yaw = clamp(_yaw - event.relative.x * mouse_sensitivity, -limit, limit)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -limit, limit)
		rotation.y = _yaw
		_barrel_pivot.rotation.x = _pitch

func _build_model() -> void:
	var base := MeshInstance3D.new()
	base.name = "Base"
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 1.25
	base_mesh.bottom_radius = 1.55
	base_mesh.height = 0.7
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.18, 0.22, 0.24))
	base.position.y = 0.35
	add_child(base)

	var head := MeshInstance3D.new()
	head.name = "RotatingHead"
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(1.9, 1.2, 1.5)
	head.mesh = head_mesh
	head.material_override = _make_material(Color(0.33, 0.37, 0.38))
	head.position.y = 1.2
	add_child(head)

	_barrel_pivot = Node3D.new()
	_barrel_pivot.name = "BarrelPivot"
	_barrel_pivot.position = Vector3(0, 1.35, -0.75)
	add_child(_barrel_pivot)

	var barrel := MeshInstance3D.new()
	barrel.name = "Barrel"
	var barrel_mesh := CylinderMesh.new()
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

func _build_fire_timer() -> void:
	_fire_timer = Timer.new()
	_fire_timer.name = "FireTimer"
	_fire_timer.wait_time = fire_interval
	_fire_timer.autostart = true
	_fire_timer.timeout.connect(_fire)
	add_child(_fire_timer)

func _fire() -> void:
	var projectile := Area3D.new()
	projectile.name = "Projectile"
	projectile.set_script(ProjectileScene)
	projectile.global_transform = _muzzle.global_transform
	get_tree().current_scene.add_child(projectile)
	projectile.call("launch", -_muzzle.global_transform.basis.z, projectile_speed)

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
