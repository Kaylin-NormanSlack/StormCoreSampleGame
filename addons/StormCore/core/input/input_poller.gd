# InputPoller.gd
# Polls Godot InputMap and emits raw input edge events.
# Engine infrastructure only.

extends Node

var bus: BaseEventBus = null
var bus_name: String = "InputBus"
var is_enabled: bool = true

# action_name -> bool
var _was_pressed: Dictionary = {}

# --------------------------------------------------
# Lifecycle
# --------------------------------------------------

func initialize() -> void:
	if GlobalBusManager.has_bus(bus_name):
		bus = GlobalBusManager.get_bus(bus_name)
	else:
		GlobalBusManager.bus_registered.connect(_on_bus_registered)

func _process(_delta: float) -> void:
	if not is_enabled or bus == null:
		return

	for action in InputMap.get_actions():
		var pressed: bool = Input.is_action_pressed(action)
		var prev: bool = _was_pressed.get(action, false)

		if pressed == prev:
			continue

		_was_pressed[action] = pressed

		var event_type := "input_pressed" if pressed else "input_released"

		bus.emit_event({
			"type": event_type,
			"action": action
		})

# --------------------------------------------------
# Bus Resolution
# --------------------------------------------------

func _on_bus_registered(name: String, registered_bus: BaseEventBus) -> void:
	if name == bus_name:
		bus = registered_bus
