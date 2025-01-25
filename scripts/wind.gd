extends Area2D

@export var wind_force : Vector2

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.apply_central_impulse(wind_force)
	
	
