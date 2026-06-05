extends Area2D

@export var speed = 150.0
var direction = Vector2.ZERO
var wlasciciel_pocisku = null

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body == wlasciciel_pocisku:
		return
		
	if body.name == "Gracz":
		if body.has_method("ginie"):
			body.ginie()
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
