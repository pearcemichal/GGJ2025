class_name Bubble
extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var panel: Panel = $Panel
@onready var sfx_pop: AudioStreamPlayer2D = $SFX_Pop

var random_force : Vector2

var hit_counter : int = 0

var popped : bool

func _ready() -> void:

	apply_central_impulse(random_force)

func set_bubble_size(factor : float):
	collision_shape_2d.scale *= factor
	panel.scale *= factor
	
func pop_da_bubble():
	sfx_pop.play();
	visible = false;
	popped = true;
	await get_tree().create_timer(1).timeout
	SignalBus.BubblePopped.emit()
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	#add_to_group("krillable")
	if body.is_in_group("popper"):
		if (hit_counter >= 1):
			pop_da_bubble()
		else:
			hit_counter += 1
