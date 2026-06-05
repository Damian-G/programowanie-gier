extends Control

const SCENA_GRA = preload("res://sceny/poziom_1.tscn")

@onready var panel_sterowania = $PanelSterowania
@onready var menu_glowne_przyciski = $CenterContainer

func _on_latwy_pressed() -> void:
	Global.poziom_trudnosci = "latwy"
	get_tree().change_scene_to_packed(SCENA_GRA)

func _on_sredni_pressed() -> void:
	Global.poziom_trudnosci = "sredni"
	get_tree().change_scene_to_packed(SCENA_GRA)

func _on_trudny_pressed() -> void:
	Global.poziom_trudnosci = "trudny"
	get_tree().change_scene_to_packed(SCENA_GRA)

func _on_sterowanie_pressed() -> void:
	panel_sterowania.visible = true
	menu_glowne_przyciski.visible = false

func _on_przycisk_wroc_pressed() -> void:
	panel_sterowania.visible = false
	menu_glowne_przyciski.visible = true
