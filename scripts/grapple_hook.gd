extends Node2D

@export var max_distance := 300.0
@export var release_boost := 1.3
@export var vertical_boost := 1.4


@onready var ray: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D


var player: CharacterBody2D
var anchor: Vector2
var rope_length := 0.0
var active := false
var momentum_time := 0.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent()
	ray.add_exception(player)
	line.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("grapple"):
		fire_grapple()
	elif event.is_action_released("grapple"):
		release_grapple()
				
func fire_grapple() -> void:	#subtract player position from the mouse postion to get the distance to travel(x and y)
	ray.target_position = (get_global_mouse_position() - global_position).limit_length(max_distance)
	ray.force_raycast_update() #makes it check NOW, not on the next physics cycle
	if ray.is_colliding():
		anchor = ray.get_collision_point()
		rope_length = global_position.distance_to(anchor)
		active = true
		line.visible = true
		
func release_grapple() -> void:
	if active:
		momentum_time = 0.4
		player.velocity *= release_boost
		if player.velocity.y < 0.0:
			player.velocity.y *= vertical_boost
	active = false
	line.visible = false
	
	
func apply_constraint() -> void:
	if not active:
		return
	var dir := (player.global_position - anchor).normalized()
	#if rope is tight (no slack)
	if player.global_position.distance_to(anchor) >= rope_length:
		#outward is the amount of momentum the player has away from anchor
		var outward := player.velocity.dot(dir)
		if outward > 0.0:
			player.velocity -= dir * outward

	
		# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	momentum_time = max(momentum_time - delta, 0.0)
	if active:
		line.points = [line.to_local(global_position), line.to_local(anchor)]
