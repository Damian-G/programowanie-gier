extends Node3D

@export var speed: float = 40.0
@export var lifetime: float = 3.0
var direction: Vector3 = Vector3.ZERO 

func _process(delta: float) -> void:
	if direction != Vector3.ZERO:
		global_position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_area_3d_area_entered(_area: Area3D) -> void:
	var cel = _area.get_parent()
	
	if cel and cel.has_method("take_hit"):
		if _area.name == "HitboxPhase1":
			cel.take_hit(1)
		elif _area.name == "HitboxPhase2":
			cel.take_hit(2)
			
		queue_free()
		return

	queue_free()
