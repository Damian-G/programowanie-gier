extends Node3D

#predkosc pocisku
@export var speed: float = 40.0
#czas zycia pocisku
@export var lifetime: float = 3.0

#kierunek lotu
var direction: Vector3 = Vector3.ZERO 

func _process(delta: float):
	#kierunek lotu, jak sie nie ruszy gracz to stoi w miejscu
	if direction != Vector3.ZERO:
		global_position += direction * speed * delta
	
	#auto destrukcja pocisku
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

#pocisk znika jak trafi w cel
func _on_area_3d_area_entered(_area: Area3D):
	queue_free()
