class_name Player
extends CharacterBody2D

@onready var jump_power: ProgressBar = $JumpPower
@onready var red_sprites: AnimatedSprite2D = $"Red Sprites"
@onready var blue_sprites: AnimatedSprite2D = $"Blue Sprites"

@export var player_id : int
@export var SPEED = 100.0
@export var JUMP_VELOCITY = 200.0

var jump_bubble : BubbleJump
var jump_dir : Vector2
var move_dir : Vector2
var facing_direction : int = 1; # Set based on player 
var jump_power_value : float
var active_animation : AnimatedSprite2D
var roll_rotation_speed = 0.032; #0.008 for bubble mode

enum player_states { Neutral, Charge, Dive, Roll, Bubbled, BubbledCharge }
var player_state : player_states = player_states.Neutral;

#region Lifecycle Functions
func _ready() -> void:
	jump_power.value = 0
	
	if player_id == 0:
		active_animation = red_sprites;
		facing_direction =-1;
	else:
		active_animation = blue_sprites;
		facing_direction = 1;
	
	active_animation.visible = true;
	set_sprite_flip();
	enter_neutral_state();

func _process(delta: float) -> void:
	match(player_state):
		player_states.Neutral:
			update_neutral();
		player_states.Charge:
			update_charge();
		player_states.Dive:
			update_dive();
		player_states.Roll:
			update_roll();
		player_states.Bubbled:
			update_bubbled();
		player_states.BubbledCharge:
			update_bubbled_charge();
			
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
	
	move_and_slide()
#endregion

#region Enter State
func enter_neutral_state() -> void:
	player_state = player_states.Neutral;
	active_animation.play("Neutral");
	active_animation.rotation = 0;

func enter_charge_state() -> void:
	player_state = player_states.Charge;
	active_animation.play("Charge");
	active_animation.rotation = 0;
	jump_power_value = 0;
	velocity.x = 0;
	move_dir.x = 0;
	
func enter_dive_state() -> void:
	player_state = player_states.Dive;
	active_animation.play("Dive");
	if jump_bubble:
		jump_bubble.queue_free()
	
	velocity = jump_dir * JUMP_VELOCITY * jump_power_value
	player_state = player_states.Dive;
	active_animation.play("Dive");
	jump_power_value = 0
	jump_power.value = jump_power_value
	
func enter_bubbled_state() -> void:
	player_state = player_states.Bubbled;
	active_animation.play("Roll");
	
func enter_bubbled_charge_state() -> void:
	player_state = player_states.BubbledCharge;
	active_animation.play("Charge");
	jump_power_value = 0;
	velocity.x = 0;
	move_dir.x = 0;
#endregion

#region Update State
func update_neutral() -> void:
	if Input.is_action_pressed("P%s_jump" % player_id):
		enter_charge_state();
		return;
	move_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_LEFT_X)
	# update facing direction from aim
	facing_direction = sign(move_dir.x);
	set_sprite_flip();

func update_charge() -> void:
	if Input.is_action_just_released("P%s_jump" % player_id):
		enter_dive_state();
		return;
	jump_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_X)
	jump_dir.y = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_Y)
	jump_power.rotation = get_angle_to(global_position + jump_dir) + 80
	if (jump_power_value < jump_power.max_value):
		jump_power_value += 0.5
		jump_power.value = jump_power_value

func update_dive() -> void:
	if jump_bubble:
		enter_bubbled_state();
	if is_on_floor():
		enter_neutral_state();
		return;
	if sign(velocity.y) != -1:
		player_state = player_states.Roll;
		active_animation.play("Roll");
	else:
		active_animation.rotation = velocity.angle();

func update_roll() -> void:
	if jump_bubble:
		enter_bubbled_state();
	if is_on_floor():
		enter_neutral_state();
		return;
	active_animation.rotation += roll_rotation_speed;
	
func update_bubbled() -> void:
	if Input.is_action_pressed("P%s_jump" % player_id):
		enter_bubbled_charge_state();
		return;
	# update facing direction from aim
	facing_direction = sign(move_dir.x);
	set_sprite_flip();
	
func update_bubbled_charge() -> void:
	if Input.is_action_just_released("P%s_jump" % player_id):
		enter_dive_state();
		return;
	jump_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_X)
	jump_dir.y = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_Y)
	jump_power.rotation = get_angle_to(global_position + jump_dir) + 80
	if (jump_power_value < jump_power.max_value):
		jump_power_value += 0.5
		jump_power.value = jump_power_value
#endregion

func set_sprite_flip() -> void:
	if facing_direction == -1:
		active_animation.flip_h = true;
	else:
		active_animation.flip_h = false;
