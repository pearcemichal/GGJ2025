class_name BubbleJump
extends Bubble


func set_bubble_size(factor : float):
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.jump_bubble = self
