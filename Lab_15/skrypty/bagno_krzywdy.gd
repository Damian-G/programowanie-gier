extends Area2D

@onready var timer_bagna = $TimerBagno 

func _ready() -> void:
	timer_bagna.stop()
	timer_bagna.timeout.connect(_on_timer_bagno_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Gracz"):
		if body.has_method("ginie"):
			body.ginie()
		timer_bagna.start(1.0) 

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Gracz"):
		timer_bagna.stop()

func _on_timer_bagno_timeout() -> void:
	var ciala_w_obszarze = get_overlapping_bodies()
	for body in ciala_w_obszarze:
		if body.is_in_group("Gracz"):
			body.ginie()
