extends CanvasLayer

@onready var plecak_label = $SmieciPlecak
@onready var mapa_label = $SmieciMapa
@onready var komunikat_label = $KomunikatPelny
@onready var tlo_alarmu = $Alarm

@onready var serca = [$KontenerZyc/Serce1, $KontenerZyc/Serce2, $KontenerZyc/Serce3]

var czas = 0.0
var max_intensywnosc_tla = 0.15

func _ready():
	add_to_group("HUD")
	
	if tlo_alarmu:
		tlo_alarmu.modulate.a = 0.0

func _process(delta):
	plecak_label.text = "Plecak: " + str(Global.w_plecaku) + "/4"
	
	mapa_label.text = "Wyrzucone: " + str(Global.smieci_wrzucone) + " / " + str(Global.smieci_na_mapie)
	
	if Global.w_plecaku >= 4:
		komunikat_label.visible = true
		
		czas += delta * 5.0
		var falowanie = (sin(czas) + 1.0) / 2.0 
		
		komunikat_label.modulate.a = falowanie
		
		if tlo_alarmu:
			tlo_alarmu.visible = true
			tlo_alarmu.modulate.a = falowanie * max_intensywnosc_tla
	else:
		komunikat_label.visible = false
		if tlo_alarmu:
			tlo_alarmu.visible = false
			tlo_alarmu.modulate.a = 0.0

func aktualizuj_zycia(ile_zycia: int):
	for i in range(serca.size()):
		if i < ile_zycia:
			serca[i].modulate = Color(1, 1, 1, 1)
		else:
			serca[i].modulate = Color(0.2, 0.2, 0.2, 0.5)
