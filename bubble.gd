class_name Bubble
extends RigidBody2D

var random_force : Vector2

func _ready() -> void:

	apply_central_impulse(random_force)
