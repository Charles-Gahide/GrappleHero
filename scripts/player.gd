class_name Player
extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var grapple = $GrappleHook
const SWING_FORCE = 150.0

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME =0.1
const LARGE_JUMP_TIME = 1
const MAX_VELOCITY = 350
const DECEL := 600.0

var fast_release := false
var coyote_timer := 0.0 
var large_jump_timer := 0.0

var anim_lock := 0.0

func start_release_anim() -> void:
	fast_release = true

func _physics_process(delta: float) -> void:
	anim_lock = max(anim_lock - delta, 0.0)
	if abs(velocity.x) < 200 or is_on_floor():
		fast_release = false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta	
		
	#Handle charged jump
	if is_on_floor() and Input.is_action_pressed("ui_s_key"):
		large_jump_timer += delta
		if anim_lock <= 0.0:
			if large_jump_timer >= LARGE_JUMP_TIME:
				anim.play("charged")
			else:
				anim.play("charging_jump")
	elif Input.is_action_just_released("ui_s_key"):
		if is_on_floor() and large_jump_timer >= LARGE_JUMP_TIME:
			velocity.y = JUMP_VELOCITY * 1.75
		large_jump_timer = 0.0
	else:
		large_jump_timer = 0.0
		if anim_lock <= 0.0:
			if fast_release:
				anim.play("charged")
			else:
				anim.play("idle")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if (grapple.active or grapple.momentum_time > 0.0) and not is_on_floor():
		velocity.x += direction * SWING_FORCE * delta
		
	elif direction:
		if abs(velocity.x) > SPEED:
			velocity.x = move_toward(velocity.x, direction * SPEED, DECEL * delta)
		else:
			velocity.x = direction * SPEED	
	else:
		if is_on_floor() or abs(velocity.y) <= SPEED:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	if not is_on_floor() and velocity.x > abs(MAX_VELOCITY):
		velocity.x = sign(velocity.x) * MAX_VELOCITY
		#sign gets the direction
		print(velocity)

	if velocity.y > MAX_VELOCITY:
		velocity.y = MAX_VELOCITY
		print(velocity)
		
#
		
	grapple.apply_constraint()
	move_and_slide()
