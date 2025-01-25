class_name BubbleSpawner
extends Node2D

@onready var timer: Timer = $"../Timer"

@export var p0_life_object : PackedScene
@export var p1_life_object : PackedScene

@export var bubble_objects : Array[PackedScene]

@export var bubble_cap : int = 25
@export var bubble_ratio : int = 5

var rng = RandomNumberGenerator.new()
var bubble_count : int = 0
var normal_rate : float

var life_timer = 10
var boost_timer = 15
var boosting : bool = false

func _ready() -> void:
	SignalBus.BubbleBoost.connect(_on_bubble_boost)
	SignalBus.BubblePopped.connect(_on_bubble_popped)
	
	normal_rate = timer.wait_time
	
	SignalBus.BubbleBoost.emit()
	
	
func spawn_bubble(obj : PackedScene):
	var bubble = obj.instantiate() as Bubble
	bubble.name = obj.resource_name
	bubble.random_force = Vector2(randi_range(-20,20),randi_range(-20,20))
	
	add_child(bubble)
	bubble.set_bubble_size(randf_range(0.5,2))

func _on_bubble_boost():
	boost_timer = 20
	boosting = true
	timer.wait_time = normal_rate / 5

func _on_bubble_popped():
	bubble_count -= 1

func _on_timer_timeout() -> void:
	
	if boosting && boost_timer > 0:
		boost_timer -= 1
	else:
		boosting = false
		timer.wait_time = normal_rate
	
	if life_timer == 0:
		spawn_bubble(p0_life_object)
		spawn_bubble(p1_life_object)
		life_timer = 10
	else:
		life_timer -= 1
	
	if bubble_count < bubble_cap:
		var obj_count = bubble_objects.size()
		var index = rng.randi_range(0,obj_count+bubble_ratio)
		if (index > obj_count-1): index = 0
		spawn_bubble(bubble_objects[index])
		bubble_count += 1
		timer.start()
