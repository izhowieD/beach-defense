extends Area3D

@export var speed: float = 34.0
@export var damage: int = 1
@export var lifetime: float = 2.4

var _velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	add_to_group("projectiles")
	monitoring = true
	monitorable = true

	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func launch(direction: Vector3) -> void:
	_velocity = direction.normalized() * speed

func get_damage() -> int:
	return damage

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
