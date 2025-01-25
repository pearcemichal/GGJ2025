class_name Player
extends CharacterBody2D

@onready var jump_power: ProgressBar = $JumpPower


@export var player_id : int

@export var SPEED = 100.0
@export var JUMP_VELOCITY = 200.0

var jump_bubble : BubbleJump

var jump_dir : Vector2
var move_dir : Vector2

var jump_power_value : float

func _ready() -> void:
	jump_power.value = 0

func _process(delta: float) -> void:
	move_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_LEFT_X)
	jump_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_X)
	jump_dir.y = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_Y)
	
	jump_power.rotation = get_angle_to(global_position + jump_dir) + 80


func _physics_process(delta: float) -> void:
	
	if jump_bubble:
		global_position = jump_bubble.global_position
		velocity = Vector2.ZERO

	# Handle jump.
	if is_on_floor():
		
		if move_dir:
			velocity.x = move_dir.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	else:
		velocity.y += get_gravity().y * delta
			
	if is_on_floor() || jump_bubble:
			
		if Input.is_action_pressed("P%s_jump" % player_id):
			if (jump_power_value < jump_power.max_value):
				jump_power_value += 0.5
				jump_power.value = jump_power_value

		if Input.is_action_just_released("P%s_jump" % player_id):
			
			if jump_bubble:
				jump_bubble.queue_free()
			
			velocity = jump_dir * JUMP_VELOCITY * jump_power_value
			
			jump_power_value = 0
			jump_power.value = jump_power_value
			
			

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
