class_name BubbleSpawner
extends Node2D

@onready var timer: Timer = $"../Timer"

@export var bubble_object : PackedScene
@export var bubble_cap : int = 50

var rng = RandomNumberGenerator.new()
var bubble_count : int = 0

func _on_timer_timeout() -> void:
	if bubble_count < bubble_cap:
		var bubble = bubble_object.instantiate() as Bubble
		bubble.random_force = Vector2(randi_range(-20,20),randi_range(-20,20))
		
		add_child(bubble)
		bubble.set_bubble_size(randf_range(0.5,2))
		bubble_count += 1
		timer.start()
