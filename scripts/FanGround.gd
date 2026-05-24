extends MeshInstance3D

@export var radius: float = 82.0
@export var angle_degrees: float = 132.0
@export var segments: int = 48
@export var center_offset_z: float = -3.0
@export var ground_color: Color = Color(0.45, 0.48, 0.32)

func _ready() -> void:
	_rebuild_mesh()

func _rebuild_mesh() -> void:
	var segment_count: int = maxi(segments, 3)
	var half_angle: float = deg_to_rad(angle_degrees * 0.5)
	var vertices: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()

	vertices.append(Vector3(0, 0, center_offset_z))
	for index in range(segment_count + 1):
		var t: float = float(index) / float(segment_count)
		var angle: float = lerpf(-half_angle, half_angle, t)
		var point: Vector3 = Vector3(sin(angle) * radius, 0, center_offset_z - cos(angle) * radius)
		vertices.append(point)

	for index in range(1, segment_count + 1):
		indices.append(0)
		indices.append(index)
		indices.append(index + 1)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	var fan_mesh: ArrayMesh = ArrayMesh.new()
	fan_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = fan_mesh
	material_override = _make_material(ground_color)

func _make_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	return material
