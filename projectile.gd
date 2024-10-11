# projectile.gd
extends Area2D

const SPEED = 600.0
var direction = Vector2.ZERO

func _ready():
	$Timer.connect("timeout", queue_free)
	# Set collision layer and mask
	set_collision_layer_value(2, true)  # Projectile is on layer 2
	set_collision_mask_value(1, true)   # Projectile collides with layer 1 (players)

func set_direction(new_direction):
	direction = new_direction
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * SPEED * delta
	var space_state = get_world_2d().get_direct_space_state()
	var ray_params = PhysicsRayQueryParameters2D.new()
	ray_params.from = global_position
	ray_params.to = global_position + direction * 10
	ray_params.collision_mask = 0b1  # Only collide with layer 1 (players)
	var result = space_state.intersect_ray(ray_params)
	if result:
		if result.collider.is_in_group("player") and result.collider.has_method("hit"):
			result.collider.hit()
		queue_free()
