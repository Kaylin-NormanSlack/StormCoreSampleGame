extends Node2D
class_name CameraTarget
	
@export var enabled = true

var _velocity = 80.0
var _camera_bus : BaseEventBus

func _ready():
	_resolve_bus()

func _physics_process(delta):
	position.y -= floor(_velocity * delta)
		
	

func _resolve_bus():
	if GlobalBusManager.has_bus("CameraBus"):
		_camera_bus = GlobalBusManager.get_bus("CameraBus")
	_connect_signals()
		
func _connect_signals() -> void:
	if not _camera_bus.event_emitted.is_connected(_on_camera_event):
		_camera_bus.event_emitted.connect(_on_camera_event)
		
func _on_camera_event(event: Dictionary):
	match(event.get("type","")):
		"camera_velocity_changed":
			var new_velocity = event.get("velocity")
			_velocity = new_velocity
