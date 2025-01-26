extends Node2D

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var anim_list : PackedStringArray

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_list = player.get_animation_list()


func _on_timer_timeout() -> void:
	var index = rng.randi_range(1, anim_list.size()-1)
	var anim = player.get_animation_list().get(index)
	player.play(anim)
	timer.start()
