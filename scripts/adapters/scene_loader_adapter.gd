extends BaseAdapter
class_name SceneLoaderAdapter


func initialize() -> void:
	preferred_bus_name = "SceneBus"

	if not SceneLoader.scene_loaded.is_connected(_on_scene_loaded):
		SceneLoader.scene_loaded.connect(_on_scene_loaded)


func get_adapter_name() -> String:
	return "SceneLoaderAdapter"


func get_category() -> String:
	return "scene"


func get_supported_events() -> Array[String]:
	return [
		"load_scene",
		"change_to_loaded_scene",
		"show_loading_screen",
		"reload_current_scene"
	]


func handle_event(event: Dictionary) -> void:
	match event.get("type", ""):
		"load_scene":
			_handle_load_scene(event)

		"change_to_loaded_scene":
			SceneLoader.change_scene_to_resource()

		"show_loading_screen":
			SceneLoader.change_scene_to_loading_screen()

		"reload_current_scene":
			SceneLoader.reload_current_scene()


func _handle_load_scene(event: Dictionary) -> void:
	var scene_path := String(
		event.get("scene_path", event.get("scene", ""))
	)

	var in_background := bool(
		event.get("in_background", false)
	)

	if scene_path.is_empty():
		push_warning("load_scene event is missing scene_path.")
		return

	SceneLoader.load_scene(scene_path, in_background)


func _on_scene_loaded() -> void:
	if bus == null:
		return

	bus.emit_event({
		"type": "scene_loaded",
		"source": get_adapter_name()
	})
