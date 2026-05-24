extends Label

var czas = 0.0

func _process(delta):
	if Global.w_plecaku >= 4:
		visible = true
		
		czas += delta * 5.0
		modulate.a = (sin(czas) + 1.0) / 2.0
	else:
		visible = false
