class_name BubbleDrop
extends Bubble

@export var loot : PackedScene

var dropped : bool = false

func drop_loot():
	if !dropped:
		var loot_drop = loot.instantiate()
		get_tree().get_root().add_child(loot_drop)
		loot_drop.global_position = global_position
		
	dropped = true
	
func set_bubble_size(factor : float):
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("popper"):
		drop_loot()
		pop_da_bubble()
