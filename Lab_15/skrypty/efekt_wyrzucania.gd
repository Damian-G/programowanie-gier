extends Node2D

func start_animacji(pozycja_startu, pozycja_kosza, tekstura_smiecia):
	global_position = pozycja_startu
	
	if has_node("Sprite2D"):
		$Sprite2D.texture = tekstura_smiecia
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "global_position", pozycja_kosza, 0.35)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN) # EASE_IN sprawi, że śmieć będzie przyspieszał zbliżając się do kosza
		
	tween.tween_property(self, "rotation", randf_range(-4.0, 4.0), 0.35)
	
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.35)
	
	tween.chain().tween_callback(queue_free)
