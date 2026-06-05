extends AnimatableBody2D

@export var przesuniecie: Vector2 = Vector2(200, 0)
@export var czas_ruchu: float = 3.0

func _ready() -> void:
	uruchom_podest()

func uruchom_podest() -> void:
	var pozycja_startowa = global_position
	var pozycja_koncowa = global_position + przesuniecie

	var tween = create_tween().set_loops()
	
	tween.tween_property(self, "global_position", pozycja_koncowa, czas_ruchu)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_property(self, "global_position", pozycja_startowa, czas_ruchu)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
