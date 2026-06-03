extends Node

@export var enemy_scene: PackedScene
@export var path_follow: PathFollow3D

#czas od startu gry
var time_elapsed: float = 0.0

#lista wrogów, kiedy i ilu się pojawi
var waves: Array = [
	{ "delay": 1.0, "count": 1, "x_positions": [-1.5, 0.0, 1.5], "z_offset": -40.0, "spawned": false },
	{ "delay": 2.0, "count": 2, "x_positions": [-1.5, 1.5], "z_offset": -50.0, "spawned": false },
	{ "delay": 3.0, "count": 3, "x_positions": [-1, -3, 0, 3, 1], "z_offset": -45.0, "spawned": false }
]

func _process(delta: float):
	#liczenie czasu
	time_elapsed += delta
	
	for wave in waves:
		#sprawdzenie czy wrogowie się pojawili, jak nie to się pojawiają
		if not wave["spawned"] and time_elapsed >= wave["delay"]:
			spawn_wave(wave)
			wave["spawned"] = true
			
	#automatyczne sprawdzanie warunku zwycięstwa
	check_level_complete()

func spawn_wave(wave_data):
	#tworzenie tylu wrogów, ile jest w count w liście
	for i in range(wave_data["count"]):
		var enemy = enemy_scene.instantiate()
		
		#dodanie wroga do świata gry
		get_tree().root.add_child(enemy)
		
		#obliczanie i ustawianie pozycji
		var spawn_pos = path_follow.global_position
		spawn_pos.x += wave_data["x_positions"][i]
		spawn_pos.z += wave_data["z_offset"]
		
		#ustawienie wyliczonej pozycji wrogowi
		enemy.global_position = spawn_pos
		
		#odświeżanie pozycji w silniku fizycznym
		enemy.force_update_transform()
		
		#podłączenie sygnału śmierci wroga pod GameManager
		enemy.died.connect(GameManager.add_score)

#funkcja sprawdzająca, czy poziom został ukończony
func check_level_complete():
	var last_wave = waves[waves.size() - 1]
	if not last_wave["spawned"]:
		return #jeśli ostatnia fala  nie wyleciała, gramy dalej
		
	var alive_enemies = get_tree().get_nodes_in_group("enemies")
	
	if alive_enemies.size() == 0:
		var alternative_count = 0
		for child in get_tree().root.get_children():
			if "Target" in child.name or child.has_signal("died"):
				alternative_count += 1
				
		#jeśli ostatnia fala się pojawiła i fizycznie nie ma nikogo na mapie to wygrana
		if alternative_count == 0:
			GameManager.level_complete.emit()
