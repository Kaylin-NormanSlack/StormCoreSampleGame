# BaseAdapter.gd
# Physical, bus-aware adapter base class
# Signal-driven only (no implicit dispatch)

extends Node
class_name BaseAdapter

"""
Responsibilities:
- Declare adapter identity
- Resolve buses by NAME at runtime
- Connect to bus signals explicitly
- Filter events by supported type
- Forward events to handle_event()
"""

# --------------------------------------------------
# Adapter Configuration (CODE-OWNED)
# --------------------------------------------------

var preferred_bus_name: String = ""
var auto_listen := true

# --------------------------------------------------
# Runtime State (Debug-visible, truthful)
# --------------------------------------------------

var bus: Node = null
var listening_bus_name: String = ""
var _is_listening := false

# --------------------------------------------------
# Lifecycle
# --------------------------------------------------

func _ready() -> void:
	# Stabilize name for Remote tree debugging
	if name.begins_with("@"):
		name = get_adapter_name()

	# Gate all resolution on StormCore readiness
	if GlobalBusManager._ready_emitted:
		_initialize_adapter()
	else:
		GlobalBusManager.connect(
			"stormcore_ready",
			_on_stormcore_ready,
			CONNECT_ONE_SHOT
		)

func _exit_tree() -> void:
	stop_listening()

# --------------------------------------------------
# StormCore Readiness
# --------------------------------------------------

func _on_stormcore_ready() -> void:
	_initialize_adapter()

func _initialize_adapter() -> void:
	if auto_listen and not preferred_bus_name.is_empty():
		listen_to_bus_named(preferred_bus_name)

# --------------------------------------------------
# Public API (Explicit, Signal-Based)
# --------------------------------------------------

func listen_to_bus_named(bus_name: String) -> void:
	# Prevent double-binding
	if _is_listening:
		return

	var resolved_bus := GlobalBusManager.get_node_or_null(bus_name)
	if resolved_bus == null:
		push_warning(
			"%s could not resolve bus '%s'" % [name, bus_name]
		)
		return

	bus = resolved_bus
	listening_bus_name = bus_name

	_subscribe_to_bus(bus)
	_is_listening = true

func stop_listening() -> void:
	if not _is_listening or bus == null:
		return

	_unsubscribe_from_bus(bus)
	bus = null
	listening_bus_name = ""
	_is_listening = false

# --------------------------------------------------
# Bus Subscription (SIGNAL ONLY)
# --------------------------------------------------

func _subscribe_to_bus(bus: Node) -> void:
	# This is the missing wire in your current setup
	if bus.has_signal("event_emitted"):
		bus.event_emitted.connect(_on_bus_event)

func _unsubscribe_from_bus(bus: Node) -> void:
	if bus.has_signal("event_emitted") and bus.event_emitted.is_connected(_on_bus_event):
		bus.event_emitted.disconnect(_on_bus_event)

# --------------------------------------------------
# Event Dispatch (NO DIRECT CALLS)
# --------------------------------------------------

func _on_bus_event(event: Dictionary) -> void:
	# Adapter decides if it cares
	if event.get("type", "") in get_supported_events():
		handle_event(event)

# --------------------------------------------------
# Adapter Identity / Metadata
# --------------------------------------------------

func get_adapter_name() -> String:
	return get_class()

func get_category() -> String:
	return "generic"

func get_supported_events() -> Array[String]:
	return []

# --------------------------------------------------
# Adapter Behavior Hook (Override in subclasses)
# --------------------------------------------------

func handle_event(event: Dictionary) -> void:
	# Subclasses implement behavior
	pass

#--------------------------------------------------
# Adapter Behavior Hook (Outbound Bus Calls)
# --------------------------------------------------

func send_event_to_bus_named(
	bus_name: String,
	event: Dictionary
) -> void:
	var target_bus := GlobalBusManager.get_node_or_null(bus_name)

	if target_bus == null:
		push_warning(
			"%s could not resolve destination bus '%s'"
			% [get_adapter_name(), bus_name]
		)
		return

	if not target_bus is BaseEventBus:
		push_warning(
			"Destination '%s' is not a BaseEventBus."
			% bus_name
		)
		return

	target_bus.emit_event(event)
