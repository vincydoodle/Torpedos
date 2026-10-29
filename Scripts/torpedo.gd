extends CharacterBody2D

var search_loop: bool = true
var i_see_you: bool = false
var locking: bool = false
var its_time: bool = false
var fire: bool = false
var fired: bool = false
var do_i_be_fancy: int = 0

var lines_color_change_time: int = 0
var turn_direction: int = [-1, 1].pick_random()

var possible_scores: Array = []
var locked_object: CharacterBody2D

var particleMesh: PackedScene = preload("res://Scenes/particle.tscn")

func _ready() -> void:
	if randi_range(0, 100) < 80:
		do_i_be_fancy = 1
	elif randi_range(0, 100) < 25:
		do_i_be_fancy = 4
		scale = Vector2(3.0, 3.0)
		for sound: AudioStreamPlayer2D in $Sounds.get_children():
			sound.pitch_scale -= 0.25
			sound.volume_db += 7
	else:
		do_i_be_fancy = 2
		scale = Vector2(1.5, 1.5)
		for sound: AudioStreamPlayer2D in $Sounds.get_children():
			sound.pitch_scale -= 0.05
			sound.volume_db += 3
	
	$Sounds/Spawn.play()
	$Sounds/Search.play()
	var heisthereparticle: Node2D = particleMesh.instantiate()
	heisthereparticle.modulate = Color(0.294 + do_i_be_fancy * 0.1, 0.0, 0.0, 1.0)
	heisthereparticle.scale = Vector2(do_i_be_fancy * 2, do_i_be_fancy * 2)
	heisthereparticle.expand = true
	heisthereparticle.position = position
	heisthereparticle.z_index = 1
	get_node("TrailParticleBox").add_child(heisthereparticle)
	
	for torpedo in get_tree().get_nodes_in_group("Torpedo"):
		add_collision_exception_with(torpedo)

func _physics_process(delta: float) -> void:
	if fire and !fired:
		if multiplayer.is_server():
			its_time = true
			fired = true
		$Sounds/Fire.play()
		$View/LeftSearchLine.default_color = Color(0.0, 0.0, 0.0, 1.0)
		$View/RightSearchLine.default_color = Color(0.0, 0.0, 0.0, 1.0)
	if its_time:
		if multiplayer.is_server(): 
			velocity -= Vector2.RIGHT.rotated(rotation) * 50
			var hit_data: KinematicCollision2D = move_and_collide(velocity * delta)
			if hit_data:
				if hit_data.get_collider() is CharacterBody2D and !hit_data.get_collider().is_in_group("Torpedo") and !Game.debug:
					if get_tree().current_scene.name == "Dodge":
						get_tree().current_scene.death(hit_data.get_collider().name)
					else:
						get_tree().current_scene.death()
					return
		var newParticle = NewParticle()
		get_node("TrailParticleBox").add_child(newParticle)
		if Game.peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED and multiplayer.is_server():
			possible_scores.append((remap(global_position.distance_to(locked_object.global_position), 0.0, 1527.35, 21.0, 1.0)) * do_i_be_fancy)
	if (global_position.x < -5400.0 or global_position.x > 5400.0 or global_position.y < -5400.0 or global_position.y > 5400.0) and multiplayer.is_server():
		if Game.peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
			Game.score += possible_scores.max() * remap($"../../TorpedoSpawner".spawn_time, 1000, 5000, 4, 1)
		queue_free()
		return

		
	if !its_time:
		if i_see_you and !locking:
			$Sounds/Lock.play()
			if multiplayer.is_server():
				locking = true
		
		if locking:
			if multiplayer.is_server():
				rotation = lerp_angle(rotation, global_position.direction_to(locked_object.global_position).angle() + PI, 6 * delta)
			
			if !$View.has_overlapping_bodies():
				if multiplayer.is_server():
					locking = false
					i_see_you = false
				$Sounds/Lock.stop()
			
			if multiplayer.is_server():
				lines_color_change_time += 1
			
			if lines_color_change_time % 12 == 0:
				if $View/LeftSearchLine.default_color == Color(1.0, 0.0, 0.0, 1.0):
					$View/LeftSearchLine.default_color = Color(1.0, 1.0, 1.0, 1.0)
					$View/RightSearchLine.default_color = Color(1.0, 1.0, 1.0, 1.0)
				elif $View/LeftSearchLine.default_color == Color(1.0, 1.0, 1.0, 1.0):
					$View/LeftSearchLine.default_color = Color(1.0, 0.0, 0.0, 1.0)
					$View/RightSearchLine.default_color = Color(1.0, 0.0, 0.0, 1.0)
			
			var view: Vector2 = change_view(-4)
			
			if view.x >= 0.0:
				if multiplayer.is_server():
					locking = false
					fire = true
				$View/LeftSearchLine.default_color = Color(0.0, 0.0, 0.0, 1.0)
				$View/RightSearchLine.default_color = Color(0.0, 0.0, 0.0, 1.0)
		
		if $View.has_overlapping_bodies() and !i_see_you:
			if multiplayer.is_server():
				if len($View.get_overlapping_bodies()) > 1:
					locked_object = $View.get_overlapping_bodies()[randi_range(0, 1)]
				else:
					locked_object = $View.get_overlapping_bodies()[0]
				i_see_you = true
			$Sounds/Search.stop()
			$Sounds/Spawn.pitch_scale = 3 / do_i_be_fancy
			$Sounds/Spawn.play()
			
		
		if search_loop and !i_see_you:
			if !$Sounds/Search.playing:
				$Sounds/Search.play()
			$View/LeftSearchLine.default_color = Color(1.0, 0.0, 0.0, 1.0)
			$View/RightSearchLine.default_color = Color(1.0, 0.0, 0.0, 1.0)
			if multiplayer.is_server():
				if $View/LeftSearchLine.get_point_position(1).x > -400:
					change_view(1)
			if multiplayer.is_server():
				rotation_degrees += 0.25 * turn_direction

func change_view(amount: float) -> Vector2:
	var left_point: Vector2 = $View/LeftSearchLine.get_point_position(1)
	var right_point: Vector2 = $View/RightSearchLine.get_point_position(1)
	var left_point_collide: Vector2 = $View/ViewCollider.polygon[2]
	var right_point_collide: Vector2 = $View/ViewCollider.polygon[1]
	left_point.x -= amount
	right_point.x += amount
	left_point_collide.x -= amount
	right_point_collide.x += amount
	$View/LeftSearchLine.set_point_position(1, left_point)
	$View/RightSearchLine.set_point_position(1, right_point)
	var new_polygon: PackedVector2Array = PackedVector2Array([
		$View/ViewCollider.polygon[0],
		right_point_collide, 
		left_point_collide
	])
	$View/ViewCollider.polygon = new_polygon
	
	return left_point

func NewParticle() -> Node2D:
	var sirparticletheparticle: Node2D = particleMesh.instantiate()
	sirparticletheparticle.modulate = Color(0.502, 0.0, 0.0, 1.0)
	sirparticletheparticle.global_position = global_position
	sirparticletheparticle.z_index = -100
	return sirparticletheparticle
