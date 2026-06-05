extends CanvasLayer

func _process(_delta: float) -> void:
	if has_node("Label") and has_node("Label2"):
		var t = Time.get_ticks_msec() * 0.005
		$Label.modulate.a = 0.6 + sin(t) * 0.4
		$Label2.modulate.a = 0.6 + sin(t) * 0.4

func _on_button_pressed() -> void:
	Global.resetuj_statystyki()
	get_tree().change_scene_to_file("res://sceny/poziom_1.tscn")


func _on_button_2_pressed() -> void:
	Engine.time_scale = 1.0 
	
	Global.resetuj_statystyki()
	
	get_tree().change_scene_to_file("res://sceny/MenuGlowne.tscn")
