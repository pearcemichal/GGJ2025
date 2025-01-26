extends Node2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	audio_stream_player_2d.play();
	
func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false;

func _on_audio_stream_player_2d_finished() -> void:
	queue_free();
