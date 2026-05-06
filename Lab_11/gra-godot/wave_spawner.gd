extends Node

@export var enemy_scene: PackedScene
@export var path_follow: PathFollow3D

#czas od startu gry
var time_elapsed: float = 0.0

#lista wrogów, kiedy i ilu sie pojawi
var waves: Array = [
	{ "delay": 1.0, "count": 1, "x_positions": [-4.0, 0.0, 4.0], "z_offset": -40.0, "spawned": false },
	{ "delay": 2.0, "count": 2, "x_positions": [-8.0, 8.0], "z_offset": -50.0, "spawned": false },
	{ "delay": 3.0, "count": 3, "x_positions": [-6, -3, 0, 3, 6], "z_offset": -45.0, "spawned": false }
]

func _process(delta: float):
	#liczenie czasu
	time_elapsed += delta
	
	for wave in waves:
		#sprawdzenie czy wrogowie się pojawili, jak nie to się pojawiają
		if not wave["spawned"] and time_elapsed >= wave["delay"]:
			spawn_wave(wave)
			wave["spawned"] = true

func spawn_wave(wave_data):
	#tworzenie tylu wrogów ile jest w count w liście
	for i in range(wave_data["count"]):
		var enemy = enemy_scene.instantiate()
		
		#dodanie wroga do świata gry
		get_tree().root.add_child(enemy)
		
		#obliczanei i ustawianie pozycji
		var spawn_pos = path_follow.global_position
		spawn_pos.x += wave_data["x_positions"][i]
		spawn_pos.z += wave_data["z_offset"]
		
		#ustawienie wyliczonej pozycji wrogowi
		enemy.global_position = spawn_pos
		
		#odświeżanie pozycji
		enemy.force_update_transform()
		
		#podłączenie punktów
		if get_parent().has_method("add_score"):
			enemy.died.connect(get_parent().add_score)
