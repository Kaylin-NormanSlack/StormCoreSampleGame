extends Node
class_name GravityComponent

## -----------------------------
## Configuration
## -----------------------------

@export var enabled := true
@export var gravity_strength := 980.0
@export var direction := 1.0   # 1 = down, -1 = up
@export var use_tween := true

## -----------------------------
## Cached references
## -----------------------------

var _body : CharacterBody2D
var _gravity_bus : BaseEventBus

## -----------------------------
## Lifecycle
## -----------------------------

func _ready() -> void:
	if not enabled:
		return

	_body = owner as CharacterBody2D
	if _body == null:
		push_warning("GravityComponent must be attached to CharacterBody2D.")
		return

	_resolve_bus()

func _exit_tree() -> void:
	if _gravity_bus and _gravity_bus.event_emitted.is_connected(_on_gravity_event):
		_gravity_bus.event_emitted.disconnect(_on_gravity_event)

## -----------------------------
## Bus Resolution
## -----------------------------

func _resolve_bus():
	if GlobalBusManager.has_bus("GravityBus"):
		_gravity_bus = GlobalBusManager.get_bus("GravityBus")
		_gravity_bus.event_emitted.connect(_on_gravity_event)
	else:
		GlobalBusManager.bus_registered.connect(_on_bus_registered)

func _on_bus_registered(name: String, bus: BaseEventBus) -> void:
	if name == "GravityBus":
		_gravity_bus = bus
		_gravity_bus.event_emitted.connect(_on_gravity_event)

## -----------------------------
## Event Handling
## -----------------------------

func _on_gravity_event(event: Dictionary) -> void:
	match event.get("type", ""):
		"gravity_changed":
			var new_strength = event.get("strength", gravity_strength)
			var new_direction = event.get("direction", direction)
			var transition = event.get("transition_time", 0.0)

			if use_tween and transition > 0.0:
				_tween_gravity(new_strength, new_direction, transition)
			else:
				gravity_strength = new_strength
				direction = new_direction

## -----------------------------
## Tween
## -----------------------------

func _tween_gravity(new_strength: float, new_direction: float, duration: float):
	var tween = create_tween()

	tween.tween_property(self, "gravity_strength", new_strength, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(self, "direction", new_direction, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

## -----------------------------
## Physics
## -----------------------------

func _physics_process(delta: float) -> void:
	if not enabled:
		return

	if _body == null:
		return

	_apply_gravity(delta)

func _apply_gravity(delta: float) -> void:
	if not _body.is_on_floor():
		_body.velocity.y += gravity_strength * direction * delta
