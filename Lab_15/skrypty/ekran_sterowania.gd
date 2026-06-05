extends Control

var czy_znika: bool = false

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not czy_znika:
		czy_znika = true
		
		var tween = create_tween()
		
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		
		tween.tween_callback(queue_free)
