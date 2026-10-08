extends Node2D

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var hide_mouse: bool = true
var hosted_scene: String

func host(scene_path: String) -> void:
	hosted_scene = scene_path
	var err: Error = peer.create_server(62965, 2)
	if err != OK:
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_connect)

func join(address: String) -> void:
	var err: Error = peer.create_client(address, 62965)
	if err != OK:
		return
	
	multiplayer.multiplayer_peer = peer

func _connect(id: int) -> void:
	if !multiplayer.is_server() or id == 1:
		return
	if get_tree().current_scene.has_method("add_player_two"):
		get_tree().current_scene.add_player_two(id)
	_share_scene.rpc(hosted_scene)

@rpc("any_peer", "call_local")
func _share_scene(scene: String) -> void:
	get_tree().change_scene_to_file(scene)

@rpc("any_peer", "call_remote")
func rpc_reconnect(ip: String) -> void:
	if Game.peer:
		Game.peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		Game.peer = ENetMultiplayerPeer.new()
	Game.join(ip)

var score: int = 0
var score_text: String = "Score: <>"
var high_score: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	high_score = loads()
	saves()

var closing: int = 0
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("Quit"):
		closing += 1
	else:
		closing = 0
	
	if Input.is_action_pressed("Menu"):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	
	if closing >= 120:
		get_tree().quit(0)
	
	if high_score < score:
		score_text = "Score: <>!"
		high_score = score
		saves()

func saves():
	var f = FileAccess.open("user://save.dat", FileAccess.WRITE)
	if f:
		f.store_32(high_score)
		f.close()

func loads() -> int:
	if not FileAccess.file_exists("user://save.dat"):
		return 0
	var f = FileAccess.open("user://save.dat", FileAccess.READ)
	if f:
		var val = f.get_32()
		f.close()
		return val
	return 0
