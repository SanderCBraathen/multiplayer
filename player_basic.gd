# player_basic.gd
extends CharacterBody2D

const SPEED = 300.0
var start_position: Vector2

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	add_to_group("player")

func _ready():
	start_position = global_position
	# Set collision layer and mask
	set_collision_layer_value(1, true)  # Player is on layer 1
	set_collision_mask_value(2, true)   # Player collides with layer 2 (projectiles)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
		move_and_slide()
		
		if Input.is_action_just_pressed("shoot"):
			shoot.rpc(get_global_mouse_position())

@rpc("any_peer", "call_local")
func shoot(target_position: Vector2):
	var main_scene = get_tree().get_root().get_node("multiplayer_test")
	if main_scene and main_scene.has_method("get_projectile_scene"):
		var projectile_scene = main_scene.get_projectile_scene()
		if projectile_scene:
			var projectile = projectile_scene.instantiate()
			projectile.global_position = global_position
			var direction = (target_position - global_position).normalized()
			projectile.set_direction(direction)
			get_parent().add_child(projectile)
		else:
			print("Projectile scene is null")
	else:
		print("Main scene not found or doesn't have get_projectile_scene method")

func hit():
	rpc("respawn")

@rpc("call_local")
func respawn():
	global_position = start_position
