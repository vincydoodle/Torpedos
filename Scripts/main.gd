extends Node2D

func _ready() -> void:
	$"Walls".z_index = 5
	$"Close Game".z_index = 100
	$Players/Player.z_index = 3
	$Score.z_index = 100

func _process(delta: float) -> void:
	if Game.closing > 0:
		$"Close Game".show()
	else:
		$"Close Game".hide()

func death():
	get_tree().change_scene_to_file("res://Scenes/heaven.tscn")
