class_name BubbleLife
extends Bubble

@export var player_id : int

func set_bubble_size(factor : float):
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("popper"):
		if body.is_in_group("players") && body.player_id != player_id:
			SignalBus.PlayerTakeDamage.emit(player_id)
			pop_da_bubble()
		else:
			apply_central_force(body.velocity * 2)
		
