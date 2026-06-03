extends Node3D

func _ready() -> void:
	#czekamy na zakończenie efektu i usuwamy obiekt z pamięci
	await get_tree().create_timer(0.8).timeout
	queue_free()
