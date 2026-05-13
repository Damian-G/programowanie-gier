extends Camera3D

@export var camera_target: Node3D 
@export var lag_speed: float = 5.0

func _process(delta: float):
	if camera_target:
		#przesunięcie kamery za celem
		global_position = global_position.lerp(camera_target.global_position, lag_speed * delta)
		
		#kamera patrzy na statek
		var player = get_tree().get_first_node_in_group("player")
		if player:
			look_at(player.global_position)
