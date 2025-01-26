class_name BubbleSpawner
extends Node2D

@onready var timer: Timer = $"../Timer"

@export var basic_bubble : Array[PackedScene]
@export var life_bubbles : Array[PackedScene]
@export var loot_bubbles : Array[PackedScene]

@export var bubble_cap : int = 25
@export var bubble_ratio : int = 5

@export var life_freq : int = 10
@export var loot_freq : int = 12

var rng = RandomNumberGenerator.new()
var bubble_count : int = 0
var normal_rate : float

var life_timer = 0
var loot_timer = 0

var boost_timer = 15
var boosting : bool = false

var spawning : bool = true;

func _ready() -> void:
	SignalBus.BubbleBoost.connect(_on_bubble_boost)
	SignalBus.BubblePopped.connect(_on_bubble_popped)
	
	normal_rate = timer.wait_time
	
	life_timer = life_freq
	loot_timer = loot_freq
	
	SignalBus.BubbleBoost.emit()
	
	
func spawn_bubble(obj : PackedScene):
	if !spawning:
		return;
	
	var bubble = obj.instantiate() as Bubble
	#bubble.name = obj.resource_name
	bubble.random_force = Vector2(randi_range(-20,20),randi_range(-20,20))
	
	add_child(bubble)
	bubble.set_bubble_size(randf_range(0.5,1.5))

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
	
	# spawn life bubbles
	if life_timer == 0:
		spawn_bubble(life_bubbles[0])
		spawn_bubble(life_bubbles[1])
		life_timer = life_freq
	else:
		life_timer -= 1
		
	# spawn loot bubbles
	#if loot_timer == 0:
		#var index = rng.randi_range(0,loot_bubbles.size()-1)
		#spawn_bubble(loot_bubbles[index])
		#loot_timer = loot_freq
	#else:
		#loot_timer -= 1
	
	#spawn basic bubbles
	if bubble_count < bubble_cap:
		var obj_count = basic_bubble.size()
		var index = rng.randi_range(0,obj_count+bubble_ratio)
		if (index > obj_count-1): index = 0
		spawn_bubble(basic_bubble[index])
		bubble_count += 1
		timer.start()
