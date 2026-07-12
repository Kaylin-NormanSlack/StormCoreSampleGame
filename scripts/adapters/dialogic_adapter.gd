extends BaseAdapter
class_name DialogicAdapter

## Bridges Dialogic signal events into StormCore buses.
##
## Expected payload:
## {
##     "bus": "CameraBus",
##     "type": "follow_target",
##     "target_group": "player"
## }
##
## Dialogic may provide this as either:
## - A Dictionary
## - A JSON-formatted String


func initialize() -> void:
	# This adapter receives events from Dialogic rather than one specific bus.
	auto_listen = false
	_connect_dialogic_signals()


func get_adapter_name() -> String:
	return "DialogicAdapter"


func get_category() -> String:
	return "dialogue"


func get_supported_events() -> Array[String]:
	# This adapter does not consume StormCore bus events.
	return []


func _connect_dialogic_signals() -> void:
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal_event):
		Dialogic.signal_event.connect(_on_dialogic_signal_event)


func _on_dialogic_signal_event(payload: Variant) -> void:
	var route := _parse_payload(payload)

	if route.is_empty():
		return

	_forward_to_stormcore(route)


func _parse_payload(payload: Variant) -> Dictionary:
	if payload is Dictionary:
		return payload.duplicate(true)

	if payload is String:
		return _parse_json_payload(payload)

	push_warning(
		"%s received an unsupported Dialogic payload type: %s"
		% [get_adapter_name(), type_string(typeof(payload))]
	)

	return {}


func _parse_json_payload(payload: String) -> Dictionary:
	if payload.is_empty():
		push_warning("%s received an empty Dialogic payload." % get_adapter_name())
		return {}

	var parsed_payload: Variant = JSON.parse_string(payload)

	if parsed_payload == null:
		push_warning(
			"%s could not parse Dialogic payload as JSON: %s"
			% [get_adapter_name(), payload]
		)
		return {}

	if not parsed_payload is Dictionary:
		push_warning(
			"%s expected the Dialogic JSON payload to contain an object."
			% get_adapter_name()
		)
		return {}

	return parsed_payload


func _forward_to_stormcore(route: Dictionary) -> void:
	var bus_name := String(route.get("bus", ""))
	var event_type := String(route.get("type", ""))

	if bus_name.is_empty():
		push_warning(
			"%s received a Dialogic event without a destination bus."
			% get_adapter_name()
		)
		return

	if event_type.is_empty():
		push_warning(
			"%s received a Dialogic event without an event type."
			% get_adapter_name()
		)
		return

	var event := route.duplicate(true)

	# Routing metadata belongs to the adapter, not the receiving bus.
	event.erase("bus")

	event["type"] = event_type
	event["source"] = "Dialogic"

	send_event_to_bus_named(bus_name, event)
