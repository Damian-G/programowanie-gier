extends Area2D

@onready var dzwiek_zebrania = $DzwiekZebrania

func _on_body_entered(body):
	if body.is_in_group("Gracz"):
		if body.aktualne_zycia < body.max_zycia:
			body.ulecz(1)
			
			set_deferred("monitoring", false)
			
			if dzwiek_zebrania:
				dzwiek_zebrania.play()
				$Zycie.visible = false 
				await dzwiek_zebrania.finished
			
			queue_free()
		else:
			print("Full, nie można zebrać!")
