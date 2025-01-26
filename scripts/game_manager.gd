extends Node2D

@onready var victory_screen: Panel = %VictoryScreen
@onready var end_message: Label = %EndMessage

@export var splash_object : PackedScene; 

var respawning_player : Player

var fullscreen_toggle : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	victory_screen.visible = false
	SignalBus.PlayerKrill.connect(_on_player_krill)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"): get_tree().reload_current_scene();
	if event.is_action_pressed("quit"): get_tree().quit()
	if event.is_action_pressed("fullscreen"):
		if fullscreen_toggle: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
		else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
		fullscreen_toggle = !fullscreen_toggle
			
		

func _on_killzone_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		var splash = splash_object.instantiate();
		add_child(splash);
		splash.global_position.x  = body.global_position.x;
		splash.global_position.y  = 70;
		
		body.position = Vector2.ZERO
		body.reset_state()


	if body.is_in_group("krillable"):
		body.queue_free()
		
func _on_player_krill(player_id : int):
	victory_screen.visible = true
	var player_string : String
	if player_id == 0: player_string = "Red"
	else: player_string = "Blue"
	
	end_message.text = "Player %s has been Krilled" % player_string
