extends Control

@onready var timer: Timer = $Timer
@onready var health_bar: HBoxContainer = $HealthBar

@export var health : int = 0
@export var player_id : int

var button_array : Array[TextureButton]

var invulnerable : bool = false
var dead : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in health_bar.get_children():
		health += 1
		button_array.append(child.get_child(0))
	
	SignalBus.PlayerTakeDamage.connect(_on_player_damaged)
	
	health = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_player_damaged(id: int) -> void:
	
	if !invulnerable && !dead:
		if id == player_id:
			health -= 1
			button_array[health].disabled = true

		else:
			invulnerable = true
			timer.start()
			
	if (health <= 0):
		dead = true
		SignalBus.PlayerKrill.emit(player_id)



func _on_timer_timeout() -> void:
	invulnerable = false
