extends CharacterBody2D

const move_speed: float = 5.0
const slow_down_speed: float = 80.0
const rotate_speed: float = 0.05
const rotate_slow_down_speed: float = 0.05
const bouncyness: float = 0.6

var move_velocity: Vector2 = Vector2.ZERO
var rotate_velocity: float = 0.0
var forward_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if multiplayer.is_server() and (name == "Player" or name.to_int() <= 1):
		$Ears.show()
		$Ears.make_current()
	if !multiplayer.is_server() and (name == "PlayerTwo" or name != "1"):
		$Ears.show()
		$Ears.make_current()

func _physics_process(delta: float) -> void:
	if Game.peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
		set_multiplayer_authority(name.to_int())
	if !is_multiplayer_authority() and Game.peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	# Rotation Physics
	if Input.get_axis("Turn Left", "Turn Right") != 0:
		rotate_velocity = move_toward(rotate_velocity, Input.get_axis("Turn Left", "Turn Right") * rotate_speed, 20.0 * delta)
	else:
		rotate_velocity = move_toward(rotate_velocity, 0.0, rotate_slow_down_speed * delta)
	
	# Forward-Backwards Physics
	if Input.is_action_just_pressed("Forward") or Input.is_action_just_pressed("Backward"):
		forward_direction = Vector2.RIGHT.rotated(rotation)
	if Input.get_axis("Forward", "Backward") != 0:
		move_velocity += forward_direction * Input.get_axis("Forward", "Backward") * move_speed
	else:
		move_velocity = move_velocity.move_toward(Vector2.ZERO, slow_down_speed * delta)
	
	var hit_data: KinematicCollision2D = move_and_collide(move_velocity * delta)
	rotation += rotate_velocity
	
	if hit_data:
		if hit_data.get_collider().get_collision_mask_value(1) and !hit_data.get_collider().is_in_group("Torpedo"):
			# Bouncy Guy :)
			move_velocity = move_velocity.bounce(hit_data.get_normal()) * bouncyness
			$Bounce.play()
		elif hit_data.get_collider().get_collision_mask_value(2) and hit_data.get_collider().is_in_group("Torpedo"):
			get_tree().current_scene.death()

func _process(delta: float) -> void:
	$Ears.rotation = -rotation


func _on_rumble_finished() -> void:
	$Rumble.play()
