extends HBoxContainer

func _ready() -> void:
	Game.score_text = "Score: <>"

func _process(delta: float) -> void:
	$"CurrentScore".text = Game.score_text.replace("<>", "<" + str(Game.score) + ">").replace("<", "").replace(">", "")
	$"HighScore".text = "High {score}".format({"score": Game.score_text}).replace("<>", "<" + str(Game.high_score) + ">").replace("<", "").replace(">", "").replace("!", "")
