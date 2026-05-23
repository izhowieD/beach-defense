extends Area3D

@export var lifetime: float = 2.4

var _velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	add_to_group("projectiles")
	monitoring = true
	monitorable = true

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.18
	shape.shape = sphere
	add_child(shape)

	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.36
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.66, 0.16)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.45, 0.08)
	material.emission_energy_multiplier = 1.2
	visual.material_override = material
	add_child(visual)

	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func launch(direction: Vector3, speed: float) -> void:
	_velocity = direction.normalized() * speed

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
