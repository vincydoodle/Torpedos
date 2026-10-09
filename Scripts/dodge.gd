extends Node2D

func _ready() -> void:
	name = "Dodge"
	
	$Players/Player.name = str(1)
	if multiplayer.is_server():
		$WaitForPlayer/Text2.text = "Your ip is " + get_local_ip()
		$WaitForPlayer.show()
		get_tree().paused = true
		
		if len(multiplayer.get_peers()) > 0:
			add_player_two(multiplayer.get_peers()[0])
	else:
		add_player_two(multiplayer.get_unique_id())

func _process(delta: float) -> void:
	if Game.closing > 0:
		$"Close Game".show()
	else:
		$"Close Game".hide()
	
	if len(multiplayer.get_peers()) < 1:
		$Disconnect.show()
		get_tree().paused = true
	else:
		get_tree().paused = false
		
	if Input.is_action_just_pressed("Ok") and $Win.visible and !multiplayer.is_server() and multiplayer.multiplayer_peer and multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		var peer_peer = multiplayer.multiplayer_peer.get_peer(1)
		if peer_peer:
			var ip: String = peer_peer.get_remote_address()
			if Game.peer:
				Game.peer.close()
				multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
				Game.peer = ENetMultiplayerPeer.new()
			Game.join(ip)


func add_player_two(id: int):
	var incoming_player: CharacterBody2D = load("res://Scenes/player_two.tscn").instantiate()
	incoming_player.name = str(id)
	incoming_player.z_index = 4
	incoming_player.global_position = Vector2(100, 0)
	
	get_tree().current_scene.get_node("Players").add_child(incoming_player)
	get_tree().current_scene.get_node("WaitForPlayer").hide()
	get_tree().paused = false


func death(player: String = "Unassigned"):
	if player == "Unassigned":
		if multiplayer.get_unique_id() == 1:
			_a_function_that_says_you_won_unfortunately.rpc("Player 2")
		else:
			_a_function_that_says_you_won_unfortunately.rpc("Player 1")
	else:
		if player == str(1):
			_a_function_that_says_you_won_unfortunately.rpc("Player 2")
		else:
			_a_function_that_says_you_won_unfortunately.rpc("Player 1")

func get_local_ip() -> String:
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			if address.begins_with("192.168.") or address.begins_with("10."):
				return address
			elif address.begins_with("172."):
				var parts = address.split(".")
				if parts.size() >  1:
					var second_octet = parts[1].to_int()
					if second_octet >= 16 and second_octet <= 31:
						return address
					
	return "127.0.0.1" 

@rpc("any_peer", "call_local")
func _a_function_that_says_you_won_unfortunately(who_won_tho: String):
	$Win.show()
	$WeHaveAWinner.play()
	$Win/Text.text = "%s Won!" % who_won_tho
	$TorpedoSpawner.queue_free()
	$Torpedos.queue_free()
