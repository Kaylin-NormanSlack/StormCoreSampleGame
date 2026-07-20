extends Node

var scene_container: Node


func _ready() -> void:
	_create_scene_container()
	_create_buses()
	_create_camera_system()
	_create_adapters()

	InputPoller.initialize()

	# This wakes every BaseAdapter that is waiting for StormCore.
	GlobalBusManager.mark_ready()

	# Readiness callbacks run synchronously when the signal is emitted,
	# but waiting one frame also allows any newly added nodes to finish _ready().
	await get_tree().process_frame

	_request_opening_scene()


# ==================================================
# Buses
# ==================================================

func _create_buses() -> void:
	GlobalBusManager.register_bus(
		"CameraBus",
		BaseEventBus.new()
	)

	GlobalBusManager.register_bus(
		"DialogBus",
		DialogBus.new()
	)

	GlobalBusManager.register_bus(
		"UIBus",
		BaseEventBus.new()
	)

	GlobalBusManager.register_bus(
		"GameBus",
		BaseEventBus.new()
	)

	GlobalBusManager.register_bus(
		"GravityBus",
		GravityBus.new()
	)

	GlobalBusManager.register_bus(
		"InputBus",
		InputBus.new()
	)

	GlobalBusManager.register_bus(
		"AudioBus",
		BaseEventBus.new()
	)

	GlobalBusManager.register_bus(
		"SceneBus",
		BaseEventBus.new()
	)


# ==================================================
# Adapters
# ==================================================

func _create_adapters() -> void:
	GlobalAdapterRegistry.adapter_folder = "res://scripts/adapters/"
	GlobalAdapterRegistry.reload()

	for adapter in GlobalAdapterRegistry.get_all():
		if not adapter is BaseAdapter:
			push_warning(
				"Registry item '%s' is not a BaseAdapter."
				% adapter.name
			)
			continue

		if adapter.get_parent() != null:
			continue

		# Adding the adapter to the tree invokes BaseAdapter._ready().
		# Do not call adapter.initialize().
		add_child(adapter)


# ==================================================
# Initial scene
# ==================================================

func _request_opening_scene() -> void:
	var scene_bus := GlobalBusManager.get_bus("SceneBus")

	if not scene_bus is BaseEventBus:
		push_error("StormRoot could not resolve SceneBus.")
		return

	scene_bus.emit_event({
		"type": "load_scene",
		"scene_path": (
			"res://addons/maaacks_game_template/"
			+ "base/nodes/opening/opening.tscn"
		),
		"in_background": false
	})


# ==================================================ame
# Camera
# ==================================================

func _create_camera_system() -> void:
	var camera_root := Node2D.new()
	camera_root.name = "CameraRoot"
	add_child(camera_root)

	var camera := Camera2D.new()
	camera.name = "MainCamera2D"
	camera_root.add_child(camera)

	var host := PhantomCameraHost.new()
	host.name = "PhantomCameraHost"
	camera.add_child(host)


# ==================================================
# Scene container
# ==================================================

func _create_scene_container() -> void:
	scene_container = Node.new()
	scene_container.name = "SceneContainer"
	add_child(scene_container)
