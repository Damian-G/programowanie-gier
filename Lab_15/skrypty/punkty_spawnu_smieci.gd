extends Node2D

const SMIEC_SCENA = preload("res://sceny/smiec.tscn") 

func _ready():
	var punkty = get_children()
	
	punkty.shuffle()
	
	var ile_smieci_stworzyc = 5 # Wartość domyślna
	
	if Global.poziom_trudnosci == "latwy":
		ile_smieci_stworzyc = min(1, punkty.size())
	elif Global.poziom_trudnosci == "sredni":
		ile_smieci_stworzyc = min(12, punkty.size())
	elif Global.poziom_trudnosci == "trudny":
		ile_smieci_stworzyc = punkty.size()

	for i in range(ile_smieci_stworzyc):
		var punkt = punkty[i]
		
		var nowy_smiec = SMIEC_SCENA.instantiate()
		
		nowy_smiec.global_position = punkt.global_position
		
		get_parent().add_child.call_deferred(nowy_smiec)
