extends Node

const Torpedo: PackedScene = preload("res://Scenes/torpedo.tscn")

var spawn_time: int = 5000
var speed_up_amount: float = 640

var start_time: int = 0
func spawn_timer() -> int:
	return Time.get_ticks_msec() - start_time

func reset_clock() -> void:
	start_time = Time.get_ticks_msec()

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): 
		return

	if spawn_timer() > spawn_time:
		spawn(randi())
		
		if spawn_time > 500:
			spawn_time -= speed_up_amount
			if not speed_up_amount <= 100:
				speed_up_amount /= 1.2
		else:
			spawn_time = 500

func spawn(id: int) -> void:
	if !multiplayer.is_server():
		return
	
	var new_torpedo_for_sale: CharacterBody2D
	
	reset_clock()
	
	new_torpedo_for_sale = Torpedo.instantiate()
	new_torpedo_for_sale.rotation = randf_range(0, 360)
	new_torpedo_for_sale.add_to_group("Torpedo")
	
	var potential_pos: Vector2 = Vector2(randi_range(-520, 520), randi_range(-520, 520))
	var players: Array = $"../Players/".get_children()
	if len(players) > 1:
		while potential_pos.distance_to(players[0].global_position) < 500 or potential_pos.distance_to(players[1].global_position) < 500:
			potential_pos = Vector2(randi_range(-520, 520), randi_range(-520, 520))
	else:
		while potential_pos.distance_to(players[0].global_position) < 500:
			potential_pos = Vector2(randi_range(-520, 520), randi_range(-520, 520))
	
	new_torpedo_for_sale.position = potential_pos
	
	new_torpedo_for_sale.name = str(id)
	
	get_parent().get_node("Torpedos").add_child(new_torpedo_for_sale, true)
