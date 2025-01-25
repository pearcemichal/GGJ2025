class_name Bubble
extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var panel: Panel = $Panel

var random_force : Vector2

func _ready() -> void:

	apply_central_impulse(random_force)

func set_bubble_size(factor : float):
	collision_shape_2d.scale *= factor
	panel.scale *= factor
