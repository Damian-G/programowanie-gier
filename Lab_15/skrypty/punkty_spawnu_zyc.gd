extends Node2D

const APTECZKA_SCENA = preload("res://sceny/apteczka.tscn")

func _ready():
	var punkty = get_children()
	punkty.shuffle()
	
	var ile_stworzyc = 4
	
	for i in range(min(ile_stworzyc, punkty.size())):
		var punkt = punkty[i]
		var nowa_apteczka = APTECZKA_SCENA.instantiate()
		nowa_apteczka.global_position = punkt.global_position
		add_child(nowa_apteczka)
