##============
#This is the base event bus class.
#every bus needs to extend from this
#in order to be discovered and registered.

extends Node
class_name BaseEventBus

signal event_emitted(event: Dictionary)

func emit_event(event: Dictionary) -> void:
	# Single point for all events.
	emit_signal("event_emitted", event)
