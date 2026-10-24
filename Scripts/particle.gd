extends Node2D

var originalScale: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Game.debug:
		queue_free()
	
	originalScale = scale.x

var fadeSpeed: float = 0.02
var expand: bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Game.debug:
		modulate -= Color(0.0, 0.0, 0.0, fadeSpeed)
		if expand:
			scale += Vector2(0.5, 0.5)
		else:
			scale -= Vector2(fadeSpeed * originalScale, fadeSpeed * originalScale)
		
		if modulate.a <= 0.0:
			queue_free()
	else:
		queue_free()
