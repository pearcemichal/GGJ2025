extends Control

@onready var label: Label = $Label

@export var health : int = 10
@export var player_id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = str(health)
	SignalBus.PlayerTakeDamage.connect(_on_player_damaged)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_player_damaged(id: int) -> void:
	if id == player_id:
		health -= 1
		print("P%s health is now %s" % [player_id, health])
		label.text = "P%s|%s" % [player_id, health]
