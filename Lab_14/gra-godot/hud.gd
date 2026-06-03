extends CanvasLayer

@onready var wynik_label: Label = $WynikLabel
@onready var zycia_label: Label = $ZyciaLabel
@onready var hp_bar: ProgressBar = $ProgressBar

@onready var dzwiek_wroga: AudioStreamPlayer = $DzwiekWroga
@onready var dzwiek_gracza: AudioStreamPlayer = $DzwiekGracza

func _ready() -> void:
	hp_bar.max_value = GameManager.player_max_hp
	hp_bar.value = GameManager.player_hp
	wynik_label.text = "Wynik: " + str(GameManager.score)
	zycia_label.text = "Życia: " + str(GameManager.lives)
	
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.hp_changed.connect(_on_hp_changed)
	
	# Zamiana nienazwanych lambd na bezpieczne metody statyczne HUD-u
	GameManager.game_over.connect(_on_game_over)
	GameManager.level_complete.connect(_on_level_complete)
	
	GameManager.enemy_killed.connect(_on_enemy_killed)
	GameManager.player_damaged.connect(_on_player_damaged)
	
	# AUTOMATYCZNE ŁĄCZENIE BOSSA (Zadanie 4)
	var boss = get_parent().get_node_or_null("Boss")
	if boss:
		boss.died.connect(_on_boss_died)

func _on_score_changed(new_score: int) -> void:
	wynik_label.text = "Wynik: " + str(new_score)

func _on_lives_changed(new_lives: int) -> void:
	zycia_label.text = "Życia: " + str(new_lives)

func _on_hp_changed(new_hp: int) -> void:
	hp_bar.value = new_hp

func _on_enemy_killed() -> void:
	dzwiek_wroga.play()

func _on_player_damaged() -> void:
	dzwiek_gracza.play()

func _on_game_over() -> void:
	#czekamy na koniec klatki, aż obiekty fizyczne znikną z pamięci
	await get_tree().process_frame
	if get_tree():
		get_tree().change_scene_to_file("res://game_over.tscn")

func _on_level_complete() -> void:
	#czekamy na koniec klatki po wygranej
	await get_tree().process_frame
	if get_tree():
		get_tree().change_scene_to_file("res://level_complete.tscn")

func _on_boss_died() -> void:
	#czekamy, aż Boss bezpiecznie wyczyści się z drzewa sceny
	await get_tree().process_frame
	GameManager.level_complete.emit()
