extends Area2D

@export var wind_force : Vector2


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			body = body as RigidBody2D
			body.apply_force(wind_force)
	
