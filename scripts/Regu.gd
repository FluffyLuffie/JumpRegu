class_name Regu

extends KinematicBody2D

# not the most beautiful code, but it does work (most of the time)

enum State{idle, walk, charge, rise, fall, stun, splat, zenoJump}

onready var sprite = $Sprite
onready var soundJump = $SoundJump
onready var soundLand = $SoundLand
onready var soundBump = $SoundBump
onready var soundSplat = $SoundSplat
onready var ap = $AnimationPlayer

var walk_speed:float = 75
var jump_speed:float = 150
var min_jump_speed:float = 100.0
var max_jump_speed:float = 450.0
var max_jump_charge:int = 30
var terminal_velocity:float = 450.0
var fall_splat_frames: int = 80

var velocity:Vector2 = Vector2()
var jump_charging:bool = false
var jump_charge:int = 0

var state = State.idle
var falling_frames: int = 0

# warning-ignore:unused_argument
func _process(delta):
	ap.play(State.keys()[state])

func _physics_process(delta):
	if state == State.zenoJump:
		return
	
	if Input.is_action_just_pressed("teleport"):
		position = get_global_mouse_position()
	
	# warning-ignore:return_value_discarded
	var next_velocity: Vector2 = move_and_slide(velocity, Vector2.UP)
	var last_col: KinematicCollision2D = get_last_slide_collision()
	
	if Input.is_action_just_pressed("jump"):
		jump_charging = true
	
	if last_col:
		#if on flat ground
		if (is_on_floor() and last_col.normal.y == 0.0) or (velocity.y >= 0.0 and last_col.normal.x == 0.0):
			#if falling fast, splat
			if state == State.fall or state == State.stun:
				if falling_frames >= fall_splat_frames:
					soundSplat.play()
					state = State.splat
				else:
					soundLand.play()
			falling_frames = 0
			
			velocity = Vector2()
			if jump_charging and Input.is_action_pressed("jump") && !GameStates.cutscene:
				if jump_charge < max_jump_charge:
					jump_charge += 1
					state = State.charge
			else:
				if jump_charging and Input.is_action_just_released("jump") && !GameStates.cutscene:
					soundJump.play()
					velocity.y = -((float(jump_charge) / max_jump_charge) * (max_jump_speed - min_jump_speed) + min_jump_speed)
					state = State.rise
					if Input.is_action_pressed("right"):
						velocity.x = jump_speed
					if Input.is_action_pressed("left"):
						velocity.x -= jump_speed
				elif state != State.splat:
					if Input.is_action_pressed("right") && !GameStates.cutscene:
						velocity.x = walk_speed
					if Input.is_action_pressed("left") && !GameStates.cutscene:
						velocity.x -= walk_speed
					
					if velocity.x != 0.0:
						state = State.walk
					else:
						state = State.idle
			if velocity.x > 0.0:
				sprite.flip_h = false
			elif velocity.x < 0.0:
				sprite.flip_h = true
		# if wall hit in air
		elif last_col.normal.y == 0.0 and velocity.x != 0.0 and not is_on_floor():
			soundBump.play()
			state = State.stun
			velocity.x = -velocity.x / 2.0
		#if ceiling
		elif is_on_ceiling():
			soundBump.play()
			state = State.stun
			velocity.y = -velocity.y / 2.0
		#if on slope
		elif last_col.normal.y != 0.0:
			state = State.stun
			falling_frames = 0
			
			velocity.y = min(next_velocity.y + GameStates.gravity * delta / 3.0, terminal_velocity / 3.0)
			#if slide right
			if get_floor_normal().x > 0.0:
				velocity.x = min(next_velocity.x + GameStates.gravity * delta / 3.0, terminal_velocity / 3.0)
			else:
				velocity.x = max(next_velocity.x - GameStates.gravity * delta / 3.0, -terminal_velocity / 3.0)
			
	else:	
		if state != State.stun:
			if velocity.y < 0.0:
				state = State.rise
			else:
				state = State.fall
		
		if velocity.y >= 0.0:
			falling_frames += 1
			
	if Input.is_action_just_released("jump"):
		jump_charging = false
		jump_charge = 0
	
	velocity.y += GameStates.gravity * delta
	velocity.y = min(velocity.y, terminal_velocity)
	
	# move to next level if valid
	var valid_x = true
	if position.x < -GameStates.level_width / 2.0:
		if GameStates.load_level(-1, 0):
			position.x += GameStates.level_width
		else:
			valid_x = false
	if position.x > GameStates.level_width / 2.0:
		if GameStates.load_level(1, 0):
			position.x -= GameStates.level_width
		else:
			valid_x = false
	if !valid_x:
		position.x = clamp(position.x, -GameStates.level_width / 2.0, GameStates.level_width / 2.0)
		if state != State.walk and velocity.x != 0.0:
			soundBump.play()
			state = State.stun
			velocity.x = -velocity.x / 2.0
	
	if position.y < -GameStates.level_height / 2.0:
		if GameStates.load_level(0, 1):
			position.y += GameStates.level_height
	if position.y > GameStates.level_height / 2.0:
		if GameStates.load_level(0, -1):
			position.y -= GameStates.level_height
			if GameStates.cutscene:
				collision_layer = 1
				collision_mask = 1

func game_clear() -> void:
	sprite.flip_h = true
	position = Vector2(0.0, 121.0)
	velocity = Vector2.ZERO
	state = State.idle
	sprite.texture = load("res://sprites/reguZeno.png")
	$AnimationPlayer.play('zenoJump')
	
func zeno_jump() -> void:
	collision_layer = 0
	collision_mask = 0
	state = State.rise
	velocity = Vector2(-60.0, -450)
