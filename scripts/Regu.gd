extends KinematicBody2D

enum State{idle, walk, charge, rise, fall, stun, splat}

var gravity:float = 700

var walk_speed:float = 75
var jump_speed:float = 150
var min_jump_speed:float = 100.0
var max_jump_speed:float = 450.0
var max_jump_charge = 30

var velocity:Vector2 = Vector2()
var jump_charging:bool = false
var jump_charge:int = 0

var state = State.idle
var animation_timer:float = 0.0

# warning-ignore:unused_argument
func _process(delta):
	if state < 2:
		$Sprite.region_rect.position = Vector2((int(animation_timer * 4) % 4 + 1) * 32, (state + 1) * 32)
	else:
		$Sprite.region_rect.position = Vector2(32, (state + 1) * 32)
	animation_timer += delta

func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
			jump_charging = true
	
	if is_on_floor():
		velocity = Vector2()
		if jump_charging and Input.is_action_pressed("jump"):
			if jump_charge < max_jump_charge:
				jump_charge += 1
				state = State.charge
		else:
			if jump_charging and Input.is_action_just_released("jump"):
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
				if Input.is_action_pressed("left"):
					velocity.x -= walk_speed
				
				if velocity.x == 0.0:
					state = State.idle
				else:
					state = State.walk
		if velocity.x > 0.0:
			$Sprite.flip_h = false
		elif velocity.x < 0.0:
			$Sprite.flip_h = true
	else:
		jump_charge = 0
		
		if is_on_wall():
			state = State.stun
			velocity.x = -velocity.x / 2.0
		elif state != State.stun:
			if velocity.y < 0.0:
				state = State.rise
			else:
				state = State.fall
	
	velocity.y += gravity * delta
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
