extends Node2D

func _ready() -> void:
	$IDidNotKnewThat.text = Game.score_text.replace("<>", "<" + str(Game.score) + ">").replace("<", "").replace(">", "")
	$IDidNotBrewThat.text = "High {score}".format({"score": Game.score_text}).replace("<>", "<" + str(Game.high_score) + ">").replace("<", "").replace(">", "").replace("!", "")
	
	$Death.play()
	await(get_tree().create_timer(2)).timeout

func _process(delta: float) -> void:
	if Game.closing > 0:
		$"Close Game".show()
	else:
		$"Close Game".hide()
	
	if Input.is_action_just_pressed("Ok"):
		Game.score = 0
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
