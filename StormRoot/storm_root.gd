extends Node

##=======================
#This script should be included with
#the StormRootScene. It also needs to be
#the first scene that launches when
#the game is ran. The purpose of this
#script is to create all of the busses
#listed below to the Global Bus Manager and to register all adapters to the
#Global Adapter Registry.
#After these are registered, they should appear
#under the approriate node as a simple bus or adapter
##=======================


var scene_container: Node
var fade_overlay: FadeOverlay



func _ready():
	_create_scene_container()
	_create_buses()
	_create_overlay_layer()
	_create_camera_system()
	_create_adapters()
	
	InputPoller.initialize()
	
	_emit_ready()
	
	GlobalBusManager.get_bus("SceneBus").emit_event(
		{
	"type": "scene_change_requested",
	"scene": "res://Scenes/DemoScene.tscn",
	"fade_out": 0.1,
	"fade_in": 0.5})

#=============================
#Create Buses
#=============================
func _create_buses():
	GlobalBusManager.register_bus("CameraBus", BaseEventBus.new())
	GlobalBusManager.register_bus("DialogBus",DialogBus.new())
	GlobalBusManager.register_bus("UIBus", BaseEventBus.new())
	GlobalBusManager.register_bus("GameBus", BaseEventBus.new())
	GlobalBusManager.register_bus("GravityBus", GravityBus.new())
	GlobalBusManager.register_bus("InputBus", InputBus.new())
	GlobalBusManager.register_bus("AudioBus", BaseEventBus.new())
	GlobalBusManager.register_bus("SceneBus", BaseEventBus.new())
	
#=============================
#Create Adapter Registry and Register all Adapters
#=============================
func _create_adapters():
	GlobalAdapterRegistry.adapter_folder = "res://scripts/adapters/"
	GlobalAdapterRegistry.reload()
	for adapter in GlobalAdapterRegistry.get_all():
		adapter.initialize()
	
#=============================
#Create Camera System
#=============================
func _create_camera_system():
	var camera_root = Node2D.new()
	camera_root.name = "CameraRoot"
	add_child(camera_root)

	var camera = Camera2D.new()
	camera.name = "MainCamera2D"
	camera_root.add_child(camera)
	
	var host = PhantomCameraHost.new()
	host.name = "PhantomCameraHost"
	camera.add_child(host)




#=============================
#Emit "Ready" signal.
#=============================
func _emit_ready():
	GlobalBusManager.mark_ready()


func _create_scene_container():
	scene_container = Node.new()
	scene_container.name = "SceneContainer"
	add_child(scene_container)

	
func _create_overlay_layer():
	var overlay = CanvasLayer.new()
	overlay.name = "OverlayLayer"
	add_child(overlay)
	fade_overlay = preload("res://Scenes/UI/fade_overlay.tscn").instantiate()
	fade_overlay.name = "FadeOverLay"
	overlay.add_child(fade_overlay)


func swap_scene(path: String) -> void:
	for child in scene_container.get_children():
		child.queue_free()

	var scene = load(path).instantiate()
	scene_container.add_child(scene)
