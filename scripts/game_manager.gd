extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_BACKSPACE):
		get_tree().reload_current_scene();
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _on_killzone_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.position = Vector2.ZERO
		body.reset_state();
	if body.is_in_group("krillable"):
		body.queue_free()
