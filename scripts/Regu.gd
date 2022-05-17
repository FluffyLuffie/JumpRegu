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
var max_jump_speed:float = 450.0
var max_jump_charge:int = 30
var terminal_velocity:float = 750.0

var velocity:Vector2 = Vector2()
var jump_charging:bool = false
var jump_charge:int = 0
var sliding:bool = false

var state = State.idle
var animation_timer:float = 0.0

# warning-ignore:unused_argument
func _process(delta):
	if state < 2:
		sprite.region_rect.position = Vector2((int(animation_timer * 4) % 4 + 1) * 32, (state + 1) * 32)
	else:
		sprite.region_rect.position = Vector2(32, (state + 1) * 32)
	animation_timer += delta

func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
			jump_charging = true
	
	sliding = false
	if is_on_floor():
		#if on flat ground
		if get_floor_normal().x == 0.0:
			#if falling fast, splat
			if state == State.fall or state == State.stun:
				if velocity.y >= terminal_velocity:
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
				else:
					if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
						animation_timer = 0.0
					
					if Input.is_action_pressed("right"):
						velocity.x = walk_speed
					if Input.is_action_just_pressed("left"):
						velocity.x -= walk_speed
					
					if velocity.x != 0.0:
						state = State.walk
					elif state != State.splat:
						state = State.idle
			if velocity.x > 0.0:
				sprite.flip_h = false
			elif velocity.x < 0.0:
				sprite.flip_h = true
		#if on slope
		else:
			sliding = true
			state = State.stun
			velocity.y = min(velocity.y + GameStates.gravity * delta / 2.0, terminal_velocity / 2.0)
			#if slide right
			if get_floor_normal().x > 0.0:
				velocity.x = min(velocity.x + GameStates.gravity * delta / 2.0, terminal_velocity / 2.0)
			else:
				velocity.x = max(velocity.x - GameStates.gravity * delta / 2.0, -terminal_velocity / 2.0)
			
	else:
		jump_charge = 0
		
		if is_on_wall() and velocity.x != 0.0:
			soundBump.play()
			state = State.stun
			velocity.x = -velocity.x / 2.0
		elif is_on_ceiling() and velocity.y < 0.0:
			soundBump.play()
			velocity.y = -velocity.y / 2.0
			var col = get_last_slide_collision()
			if col.normal.x != 0.0:
				velocity.x = velocity.x / 2.0
			
		if state != State.stun:
			if velocity.y < 0.0:
				state = State.rise
			else:
				state = State.fall
	
	if !sliding:
		velocity.y += GameStates.gravity * delta
	velocity.y = min(velocity.y, terminal_velocity)
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
	
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
		if velocity.x != 0.0:
			soundBump.play()
			state = State.stun
			velocity.x = -velocity.x / 2.0
	
	if position.y < -GameStates.level_height / 2.0:
		position.y += GameStates.level_height
# warning-ignore:return_value_discarded
		GameStates.load_level(0, 1)
	if position.y > GameStates.level_height / 2.0:
		position.y -= GameStates.level_height
# warning-ignore:return_value_discarded
		GameStates.load_level(0, -1)
