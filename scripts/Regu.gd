extends KinematicBody2D

enum State{idle, walk, charge, rise, fall, stun, splat}

onready var sprite = $Sprite
onready var soundJump = $SoundJump
onready var soundLand = $SoundLand
onready var soundBump = $SoundBump
onready var soundSplat = $SoundSplat

var walk_speed:float = 75
var jump_speed:float = 150
var min_jump_speed:float = 100.0
var max_jump_speed:float = 475.0
var max_jump_charge:int = 30
var terminal_velocity:float = 450.0
var fall_splat_frames: int = 80

var velocity:Vector2 = Vector2()
var jump_charging:bool = false
var jump_charge:int = 0
var sliding:bool = false

var state = State.idle
var animation_timer:float = 0.0
var falling_frames: int = 0

# warning-ignore:unused_argument
func _process(delta):
	if state < 2:
		sprite.region_rect.position = Vector2((int(animation_timer * 4) % 4) * 32, state * 32)
	else:
		sprite.region_rect.position = Vector2(0, state * 32)
	animation_timer += delta

func _physics_process(delta):
	# warning-ignore:return_value_discarded
	var next_velocity: Vector2 = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("jump"):
		jump_charging = true
	
	sliding = false
	if is_on_floor():
		#if on flat ground
		if get_floor_normal().x == 0.0:
			#if falling fast, splat
			if state == State.fall or state == State.stun:
				if falling_frames >= fall_splat_frames:
					soundSplat.play()
					state = State.splat
				else:
					soundLand.play()
			
			velocity = Vector2()
			if jump_charging and Input.is_action_pressed("jump"):
				if jump_charge < max_jump_charge:
					jump_charge += 1
					state = State.charge
			else:
				if jump_charging and Input.is_action_just_released("jump"):
					soundJump.play()
					velocity.y = -((float(jump_charge) / max_jump_charge) * (max_jump_speed - min_jump_speed) + min_jump_speed)
					state = State.rise
					if Input.is_action_pressed("right"):
						velocity.x = jump_speed
					if Input.is_action_pressed("left"):
						velocity.x -= jump_speed
				elif state != State.splat:
					if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
						animation_timer = 0.0
					
					if Input.is_action_pressed("right"):
						velocity.x = walk_speed
					if Input.is_action_pressed("left"):
						velocity.x -= walk_speed
					
					if velocity.x != 0.0:
						state = State.walk
					else:
						state = State.idle
			if velocity.x > 0.0:
				sprite.flip_h = false
			elif velocity.x < 0.0:
				sprite.flip_h = true
		#if on slope
		else:
			sliding = true
			state = State.stun
			velocity.y = min(next_velocity.y + GameStates.gravity * delta / 2.0, terminal_velocity / 2.0)
			#if slide right
			if get_floor_normal().x > 0.0:
				velocity.x = min(next_velocity.x + GameStates.gravity * delta / 2.0, terminal_velocity / 2.0)
			else:
				velocity.x = max(next_velocity.x - GameStates.gravity * delta / 2.0, -terminal_velocity / 2.0)
		
		falling_frames = 0
			
	else:
		jump_charge = 0
		
		if is_on_wall() and velocity.x != 0.0:
			soundBump.play()
			state = State.stun
			velocity.x = -velocity.x / 2.0
		elif is_on_ceiling() and velocity.y < 0.0:
			soundBump.play()
			velocity.y = -velocity.y / 2.0
			
		if state != State.stun:
			if velocity.y < 0.0:
				state = State.rise
			else:
				state = State.fall
		
		if velocity.y >= 0.0:
			falling_frames += 1
	
	if !sliding:
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
