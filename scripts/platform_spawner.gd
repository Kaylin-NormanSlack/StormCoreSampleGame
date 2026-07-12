extends Node2D
class_name PlatformSpawner

var _camera_bus : BaseEventBus

@export var platform_scene: PackedScene
@export var vertical_spacing := 200.0

var _camera_target: Node2D
var _world_velocity := -80.0
var _last_spawn_y := 0.0
var _gravity_direction := 1.0

func _ready():
	_camera_target = get_node("../CameraTarget")
	_camera_bus = GlobalBusManager.get_bus("CameraBus")
	_camera_bus.event_emitted.connect(_on_event)
	
	
func _on_event(event: Dictionary):
	match event.get("type", ""):
		"world_velocity_changed":
			_world_velocity = event.get("velocity", _world_velocity)
		"gravity_changed":
			_gravity_direction = event.get("direction", _gravity_direction)

func _physics_process(delta):
	_check_spawn()

func _check_spawn():
	var viewport_size = get_viewport().get_visible_rect().size
	var cam_y = _camera_target.global_position.y

	if _world_velocity < 0: # moving up
		while _last_spawn_y > cam_y - viewport_size.y:
			_spawn_platform(_last_spawn_y - vertical_spacing)
	else: # moving down
		while _last_spawn_y < cam_y + viewport_size.y:
			_spawn_platform(_last_spawn_y + vertical_spacing)

func _spawn_platform(y_pos):
	var platform = platform_scene.instantiate()
	platform.position.y = y_pos
	platform.position.x = _random_x()
	add_child(platform)
	_last_spawn_y = y_pos

func _random_x():
	var viewport_size = get_viewport().get_visible_rect().size
	var cam_x = _camera_target.global_position.x
	return randf_range(
		cam_x - viewport_size.x / 2,
		cam_x + viewport_size.x / 2
	)
