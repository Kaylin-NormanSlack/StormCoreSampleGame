extends Node
class_name SceneReadyComponent

@export var camera_name: String = ""
@export var activate_camera_on_ready: bool = true

func _ready():
	if not activate_camera_on_ready:
		return

	if camera_name == "":
		return

	var bus = GlobalBusManager.get_bus("CameraBus")
	if bus == null:
		return

	bus.emit_event({
		"type": "camera_active",
		"camera_name": camera_name
	})
