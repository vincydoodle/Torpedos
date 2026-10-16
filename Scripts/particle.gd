extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var fadeSpeed: float = 0.02
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate -= Color(0.0, 0.0, 0.0, fadeSpeed)
	
	if modulate.a <= 0.0:
		queue_free()
