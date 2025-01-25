class_name BubbleSpawner
extends Node2D

@onready var timer: Timer = $"../Timer"

@export var bubble_object : Array[PackedScene]
@export var bubble_cap : int = 50
@export var bubble_ratio : int = 5

var rng = RandomNumberGenerator.new()
var bubble_count : int = 0

func _ready() -> void:
	SignalBus.BubblePopped.connect(_on_bubble_popped)

func _on_bubble_popped():
	bubble_count -= 1

func _on_timer_timeout() -> void:
	if bubble_count < bubble_cap:
		var index = rng.randi_range(0,bubble_object.size()+bubble_ratio)
		if (index > bubble_object.size()-1): index = 0
		var bubble = bubble_object[index].instantiate() as Bubble
		bubble.random_force = Vector2(randi_range(-20,20),randi_range(-20,20))
		
		add_child(bubble)
		bubble.set_bubble_size(randf_range(0.5,2))
		bubble_count += 1
		timer.start()
