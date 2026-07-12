extends BaseAdapter
class_name PhantomCameraAdapter

@export var camera_path: NodePath
var _camera: PhantomCamera2D
var _host: Node


func initialize():
	preferred_bus_name = "CameraBus"
	listen_to_bus_named(preferred_bus_name)
	_resolve_camera()

func _resolve_camera():
	_host = get_tree().get_root().find_child("PhantomCameraHost", true, false)

	if _host == null:
		push_error("PhantomCameraHost not found.")
		return

	_camera = PhantomCamera2D.new()
	_host.add_child(_camera)


func get_adapter_name() -> String:
	return "PhantomCameraAdapter"
	


func _set_camera(prop: String, value) -> void:
	if not _camera:
		return

	if not _camera.has_property(prop):
		push_warning("PhantomCamera has no property '%s'" % prop)
		return

	_camera.set(prop, value)

func get_supported_events():
	return [
		"follow_target",
		"camera_priority",
		"camera_active",
		"camera_lull"
	]


func handle_event(event: Dictionary) -> void:
	if _camera == null:
		return

	match event.get("type", ""):
		# --- Target & follow ---
		"follow_target":
			_handle_follow_target(event)

		# --- Motion feel / lull ---
		"camera_lull":
			_handle_camera_lull(event)

		"camera_priority":
			_handle_camera_priority(event)
		
		"camera_active":
			_handle_camera_active(event)

	
func _handle_follow_target(event):
	var target = event.get("value")
	if target == null:
		return
	
	_set_camera("follow_target", target)


func _handle_camera_lull(event):
	pass
	
func _handle_camera_priority(event):
	var value = event.get("value")
	if value == null:
		return
	
	_set_camera("priority", value)

	
func _handle_camera_active(event):
	var value = event.get("value")
	if value == null:
		return
	
	_set_camera("enabled", value)
