extends Node2D

const WROG_SCENA = preload("res://sceny/wrog.tscn") 

func _ready():
	var punkty = get_children()
	
	punkty.shuffle()
	
	var ile_wrogow_stworzyc = 2 
	
	if Global.poziom_trudnosci == "latwy":
		ile_wrogow_stworzyc = min(2, punkty.size())
	elif Global.poziom_trudnosci == "sredni":
		ile_wrogow_stworzyc = min(5, punkty.size())
	elif Global.poziom_trudnosci == "trudny":
		ile_wrogow_stworzyc = min(10, punkty.size())

	for i in range(ile_wrogow_stworzyc):
		var punkt = punkty[i]
		
		var nowy_wrog = WROG_SCENA.instantiate()
		nowy_wrog.global_position = punkt.global_position
		
		get_parent().add_child.call_deferred(nowy_wrog)
