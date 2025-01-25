extends Area2D

@export var wind_force : Vector2

var group : Array[RigidBody2D]

func _physics_process(delta: float) -> void:
	if (group.size() > 0):
		for body in group:
			body.add_constant_central_force(wind_force)

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		group.append(body)
		
func _on_body_exited(body: Node2D) -> void:
	group.remove_at(group.find(body))
	body.add_constant_central_force(Vector2.ZERO)
	
