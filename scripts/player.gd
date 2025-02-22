class_name Player
extends CharacterBody2D

@onready var jump_power: ProgressBar = $JumpPower
@onready var red_sprites: AnimatedSprite2D = $"Red Sprites"
@onready var blue_sprites: AnimatedSprite2D = $"Blue Sprites"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


@onready var sfx_jump: AudioStreamPlayer2D = $SFX_Jump
@onready var sfx_charge: AudioStreamPlayer2D = $SFX_charge

@export var player_id : int
@export var SPEED = 100.0
@export var JUMP_VELOCITY = 150.0

var jump_bubble : BubbleJump
var jump_dir : Vector2
var move_dir : Vector2
var facing_direction : int = 1; # Set based on player 
var jump_power_value : float
var active_animation : AnimatedSprite2D
var roll_rotation_speed = 0.05;
var jump_charge_speed = 0.1; # default was 0.5;

enum player_states { Neutral, Walk, Charge, Dive, Roll, Bubbled, BubbledCharge }
var player_state : player_states = player_states.Neutral;

var timeout : bool = false
var wall_lock : bool = false

var box_scale : float

#region Lifecycle Functions
func _ready() -> void:
	jump_power.value = 0
	
	jump_power.visible = false
	box_scale = 1.395
	
	# set collision layers
	if player_id == 1: 
		set_collision_layer_value(1,false)
		set_collision_mask_value(1,false)
	else:
		set_collision_mask_value(2,false)
		set_collision_mask_value(2,false)
	
	if player_id == 0:
		active_animation = red_sprites;
		facing_direction =-1;
	else:
		active_animation = blue_sprites;
		facing_direction = 1;
		
	red_sprites.visible = false
	blue_sprites.visible = false
	
	active_animation.visible = true;
	set_sprite_flip();
	enter_neutral_state();

func _process(delta: float) -> void:
	if (!timeout):
		match(player_state):
			player_states.Neutral:
				update_neutral(delta);
			player_states.Walk:
				update_walk_state(delta);
			player_states.Charge:
				update_charge(delta);
			player_states.Dive:
				update_dive(delta);
			player_states.Roll:
				update_roll(delta);
			player_states.Bubbled:
				update_bubbled();
			player_states.BubbledCharge:
				update_bubbled_charge(delta);
			
func _physics_process(delta: float) -> void:
	if (!timeout):

		if jump_bubble:
			global_position = jump_bubble.global_position
			velocity = Vector2.ZERO
			
		if !wall_lock:
			if is_on_wall():
				wall_lock = true
				for i in range(get_slide_collision_count()):
					var wall = get_slide_collision(i)
					velocity.x += wall.get_normal().x * 100
				#velocity.x += 1000

		move_and_slide()
#endregion

#region Enter State
func enter_neutral_state() -> void:
	wall_lock = false
	player_state = player_states.Neutral;
	active_animation.play("Neutral");
	active_animation.rotation = 0;
	velocity.x = 0;
	velocity.y = 0;
	jump_power.visible = false

func enter_walk_state() -> void:
	player_state = player_states.Walk;
	active_animation.play("Walk");

func enter_charge_state() -> void:
	player_state = player_states.Charge;
	active_animation.play("Charge");
	active_animation.rotation = 0;
	jump_power_value = 0;
	velocity.x = 0;
	move_dir.x = 0;
	sfx_charge.play()
	jump_power.visible = true
	
func enter_dive_state() -> void:
	player_state = player_states.Dive;
	active_animation.play("Dive");
	if jump_bubble:
		jump_bubble.pop_da_bubble()
		jump_bubble = null
	
	velocity = jump_dir * JUMP_VELOCITY * jump_power_value
	player_state = player_states.Dive;
	active_animation.play("Dive");
	jump_power_value = 0
	jump_power.value = jump_power_value
	set_sprite_flip();
	sfx_jump.play()
	collision_shape_2d.scale = Vector2(box_scale,box_scale)

func enter_roll_state() -> void:
	player_state = player_states.Roll;
	active_animation.play("Roll");

func enter_bubbled_state() -> void:
	player_state = player_states.Bubbled;
	active_animation.play("Roll");
	set_sprite_flip();
	jump_power.visible = false
	collision_shape_2d.scale = Vector2(0.25,0.25)
	
	
	
func enter_bubbled_charge_state() -> void:
	player_state = player_states.BubbledCharge;
	active_animation.play("Charge");
	jump_power_value = 0;
	velocity.x = 0;
	move_dir.x = 0;
	jump_power.visible = true
#endregion

#region Update State
func update_neutral(delta: float) -> void:
	if jump_bubble:
		enter_bubbled_state();
		return;
	if Input.is_action_pressed("P%s_jump" % player_id) && is_on_floor():
		enter_charge_state();
		return;
	if abs(Input.get_joy_axis(player_id,JOY_AXIS_LEFT_X)) > 0.25:
		enter_walk_state();
		return;
		
	if !is_on_floor():
		apply_gravity(delta);

func update_walk_state(delta: float) -> void:
	if jump_bubble:
		enter_bubbled_state();
		return;
	if Input.is_action_pressed("P%s_jump" % player_id) && is_on_floor():
		enter_charge_state();
		return;
	
	if abs(Input.get_joy_axis(player_id,JOY_AXIS_LEFT_X)) <= 0.25:
		enter_neutral_state();
		return;
	
	move_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_LEFT_X)
	facing_direction = sign(move_dir.x);
	set_sprite_flip();
	velocity.x = move_dir.x * SPEED
	if !is_on_floor():
		apply_gravity(delta);

func update_charge(delta: float) -> void:
	if jump_bubble:
		enter_bubbled_state();
		return;
	if Input.is_action_just_released("P%s_jump" % player_id):
		enter_dive_state();
		return;
	jump_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_X)
	jump_dir.y = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_Y)
	jump_power.rotation = get_angle_to(global_position + jump_dir) + 80
	if (jump_power_value < jump_power.max_value):
		jump_power_value += jump_charge_speed * delta * 100;
		jump_power.value = jump_power_value
	facing_direction = sign(jump_dir.x);
	set_sprite_flip();

func update_dive(delta: float) -> void:
	
	if jump_bubble:
		enter_bubbled_state();
		return;
		
	if is_on_floor() && velocity.y > 0:
		enter_neutral_state();
		return;
	
	if sign(velocity.y) != -1:
		enter_roll_state();
		return;
		
	
	#facing left
	if facing_direction == -1:
		active_animation.rotation = deg_to_rad(rad_to_deg(velocity.angle()) + 180 - 10)
	else:
		active_animation.rotation = deg_to_rad(rad_to_deg(velocity.angle()) +10)
	apply_gravity(delta);

func update_roll(delta: float) -> void:
	if jump_bubble:
		enter_bubbled_state();
		return;
		
	if is_on_floor():
		enter_neutral_state();
		return;
		
	if facing_direction == -1:
		active_animation.rotation -= roll_rotation_speed;
	else:
		active_animation.rotation += roll_rotation_speed;
	
	apply_gravity(delta);
	
func update_bubbled() -> void:
	if Input.is_action_pressed("P%s_jump" % player_id):
		enter_bubbled_charge_state();
		return;
	active_animation.rotation += roll_rotation_speed;
	
func update_bubbled_charge(delta: float) -> void:
	if Input.is_action_just_released("P%s_jump" % player_id):
		enter_dive_state();
		return;
	jump_dir.x = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_X)
	jump_dir.y = Input.get_joy_axis(player_id,JOY_AXIS_RIGHT_Y)
	jump_power.rotation = get_angle_to(global_position + jump_dir) + 80
	
	active_animation.rotation = get_angle_to(global_position + jump_dir) - 30;
	
	if (jump_power_value < jump_power.max_value):
		jump_power_value += jump_charge_speed * delta * 100
		jump_power.value = jump_power_value
#endregion

func set_sprite_flip() -> void:
	if facing_direction == -1:
		active_animation.flip_h = true;
	else:
		active_animation.flip_h = false;

func apply_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * delta;

func reset_state() -> void:
	jump_bubble = null
	collision_shape_2d.scale = Vector2(box_scale,box_scale)
	enter_neutral_state();
