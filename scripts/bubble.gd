class_name BubbleDrop
extends Bubble

@export var loot : PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("popper"):
		pop_da_bubble()
