extends Node
class_name CameraFollowOnStartComponent

@export var camera_bus_name: String = "CameraBus"

var _bus

func _ready():
	var bus_manager = get_tree().get_first_node_in_group("bus_manager")
	if bus_manager == null:
		push_warning("Bus manager not found.")
		return

	_bus = bus_manager.get_bus(camera_bus_name)
	if _bus == null:
		push_warning("CameraBus not found.")
		return

	var target = get_node_or_null("Player")
	if target == null:
		push_warning("Target not found.")
		return

	_bus.emit_event({
		"type": "follow_target",
		"value":"Player"})
