extends Node3D

func _ready():
	$Area3D.area_entered.connect(_on_hit)

func _on_hit(_area: Area3D):
	print("Trafiony!")
	
	#glowna scena i dodawanie pkt
	var main_node = get_tree().current_scene
	if main_node.has_method("add_score"):
		main_node.add_score(100)
	
	#usuwanie pocisku
	_area.queue_free()
	
	#usuwanie celu
	queue_free()
