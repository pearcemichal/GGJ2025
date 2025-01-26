class_name BubbleJump
extends Bubble

var occupied : Player

func set_bubble_size(factor : float):
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:

	if body.is_in_group("players") && !popped:
		#if occupied:
			#occupied.reset_state()
			#pop_da_bubble()
		
		#else:
		body.jump_bubble = self
		occupied = body
		apply_force(body.velocity / 2)
