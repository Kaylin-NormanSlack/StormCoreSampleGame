extends Node
class_name BaseAdapter

## Physical, bus-aware adapter base class.
##
## Initialization authority:
##     BaseAdapter._ready()
##
## StormRoot and registries may instantiate adapters and add them to the tree,
## but they must not call initialize() manually.

var preferred_bus_name: String = ""
var auto_listen: bool = true

var bus: BaseEventBus = null
var listening_bus_name: String = ""

var _is_listening: bool = false
var _is_initialized: bool = false


# ==================================================
# Lifecycle
# ==================================================

func _ready() -> void:
	if name.begins_with("@"):
		name = get_adapter_name()

	if GlobalBusManager._ready_emitted:
		_initialize_adapter()
	else:
		if not GlobalBusManager.stormcore_ready.is_connected(
			_on_stormcore_ready
		):
			GlobalBusManager.stormcore_ready.connect(
				_on_stormcore_ready,
				CONNECT_ONE_SHOT
			)


func _exit_tree() -> void:
	stop_listening()


# ==================================================
# StormCore initialization
# ==================================================

func _on_stormcore_ready() -> void:
	_initialize_adapter()


func _initialize_adapter() -> void:
	if _is_initialized:
		return

	_is_initialized = true

	# Subclass-specific setup happens here.
	initialize()

	# Bus binding happens only after the subclass has selected its bus.
	if auto_listen and not preferred_bus_name.is_empty():
		listen_to_bus_named(preferred_bus_name)


## Override this in subclasses.
##
## Use it to:
## - select preferred_bus_name;
## - resolve plugin dependencies;
## - connect external plugin signals;
## - create adapter-owned runtime objects.
##
## Do not call this manually.
func initialize() -> void:
	pass


# ==================================================
# Bus access
# ==================================================

func listen_to_bus_named(bus_name: String) -> void:
	if _is_listening:
		return

	var resolved_bus := GlobalBusManager.get_bus(bus_name)

	if resolved_bus == null:
		push_warning(
			"%s could not resolve bus '%s'."
			% [get_adapter_name(), bus_name]
		)
		return

	if not resolved_bus is BaseEventBus:
		push_warning(
			"%s resolved '%s', but it is not a BaseEventBus."
			% [get_adapter_name(), bus_name]
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


func send_event_to_bus_named(
	bus_name: String,
	event: Dictionary
) -> void:
	var target_bus := GlobalBusManager.get_bus(bus_name)

	if target_bus == null:
		push_warning(
			"%s could not resolve destination bus '%s'."
			% [get_adapter_name(), bus_name]
		)
		return

	if not target_bus is BaseEventBus:
		push_warning(
			"%s cannot send to '%s' because it is not a BaseEventBus."
			% [get_adapter_name(), bus_name]
		)
		return

	target_bus.emit_event(event)


# ==================================================
# Bus subscription
# ==================================================

func _subscribe_to_bus(target_bus: BaseEventBus) -> void:
	if not target_bus.event_emitted.is_connected(_on_bus_event):
		target_bus.event_emitted.connect(_on_bus_event)


func _unsubscribe_from_bus(target_bus: BaseEventBus) -> void:
	if target_bus.event_emitted.is_connected(_on_bus_event):
		target_bus.event_emitted.disconnect(_on_bus_event)


func _on_bus_event(event: Dictionary) -> void:
	if event.get("type", "") in get_supported_events():
		handle_event(event)


# ==================================================
# Adapter metadata
# ==================================================

func get_adapter_name() -> String:
	return get_class()


func get_category() -> String:
	return "generic"


func get_supported_events() -> Array[String]:
	return []


# ==================================================
# Adapter behavior
# ==================================================

func handle_event(_event: Dictionary) -> void:
	pass
