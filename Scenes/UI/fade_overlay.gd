extends CanvasLayer
class_name FadeOverlay

@onready var rect: ColorRect = $ColorRect


func fade_out(duration: float) -> void:
	rect.visible = true
	rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float) -> void:
	rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	await tween.finished

	rect.visible = false
