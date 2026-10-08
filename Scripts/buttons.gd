extends VBoxContainer

var selected_button: int = 0
var num_buttons: int = 3
var current_menu: int = 1

func _ready() -> void:
	
	Game.score = 0
	num_buttons = 3
	
	get_tree().paused = false
	
	if Game.loads() != 0:
		$ResetScore.show()
		num_buttons = 4
	
	if Game.peer:
		Game.peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		Game.peer = ENetMultiplayerPeer.new()

func _process(delta: float) -> void:
	if Game.closing > 0:
		$"../Close Game".show()
	else:
		$"../Close Game".hide()
	
	if InputEvent:
		if current_menu == 1:
			if selected_button == 1:
				$Play.grab_focus()
			
			elif selected_button == 2:
				$Host.grab_focus()
			elif selected_button == 3:
				$Join.grab_focus()
			elif selected_button == 4:
				$ResetScore.grab_focus()
		elif current_menu == 2:
			if selected_button == 1:
				$"../HostMenu/Box/dodge".grab_focus()
				$"../HostMenu/Box/dodge/Tooltip".show()
				$"../HostMenu/Box/dictatorer/Tooltip".hide()
				$"../HostMenu/Box/thefpsone/Tooltip".hide()
			elif selected_button == 2:
				$"../HostMenu/Box/dictatorer".grab_focus()
				$"../HostMenu/Box/dictatorer/Tooltip".show()
				$"../HostMenu/Box/thefpsone/Tooltip".hide()
				$"../HostMenu/Box/dodge/Tooltip".hide()
			elif selected_button == 3:
				$"../HostMenu/Box/thefpsone".grab_focus()
				$"../HostMenu/Box/thefpsone/Tooltip".show()
				$"../HostMenu/Box/dictatorer/Tooltip".hide()
				$"../HostMenu/Box/dodge/Tooltip".hide()
		elif current_menu == 3:
			if selected_button == 1:
				$"../JoinMenu/Box/IPInput".grab_focus()
			elif selected_button == 2:
				$"../JoinMenu/Box/Submit".grab_focus()
	
	if Input.is_action_just_pressed("Ok"):
		var focused = get_viewport().gui_get_focus_owner()
		$"../Sounds/Press".play()
		if focused and focused is Button:
			var pressed_color = focused.get_theme_color("font_pressed_color", "Button")
			var normal_color = focused.get_theme_color("font_color", "Button")
			focused.modulate = pressed_color
			create_tween().tween_property(focused, "modulate", normal_color, 0.1)
			focused.emit_signal("pressed")
	elif Input.is_action_just_pressed("Forward"):
		$"../Sounds/Focus".play()
		if !selected_button < 2:
			selected_button -= 1
		else:
			selected_button = num_buttons
	
	elif Input.is_action_just_pressed("Backward"):
		$"../Sounds/Focus".play()
		if !selected_button >= num_buttons:
			selected_button += 1
		else:
			selected_button = 1
		


func _on_play_pressed() -> void:
	await(get_tree().create_timer(0.06)).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_host_pressed() -> void:
	await(get_tree().create_timer(0.06)).timeout
	Game.host("res://Scenes/dodge.tscn")
	get_tree().change_scene_to_file("res://Scenes/dodge.tscn")

func _on_join_pressed() -> void:
	selected_button = 1
	current_menu = 3
	num_buttons = 2
	$"../JoinMenu".show()
	hide()


func _on_reset_score_pressed() -> void:
	var f = FileAccess.open("user://save.dat", FileAccess.WRITE)
	if f:
		f.close()
		$ResetScore/Success.show()
	Game.high_score = 0

func _on_submit_pressed() -> void:
	await(get_tree().create_timer(0.06)).timeout
	Game.join($"../JoinMenu/Box/IPInput".text)
