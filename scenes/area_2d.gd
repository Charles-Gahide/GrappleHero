extends Area2D

var grapple 

@export var spawn_point: Marker2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		grapple = body.get_node("GrappleHook")
		if grapple.active:
			grapple.release_grapple()
		grapple.momentum_time = 0.0	
		body.global_position = spawn_point.global_position
		body.velocity = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	pass
