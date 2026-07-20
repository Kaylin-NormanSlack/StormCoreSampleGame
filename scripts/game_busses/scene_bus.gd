extends BaseEventBus
class_name SceneBus

## ============================================================================
## SceneBus
##
## Routes scene-related requests and notifications.
##
## Example events:
##
## {
##     "type": "load_scene",
##     "scene_path": "res://game/scenes/level_01.tscn",
##     "in_background": false
## }
##
## {
##     "type": "change_to_loaded_scene"
## }
##
## {
##     "type": "reload_current_scene"
## }
##
## {
##     "type": "scene_loaded"
## }
##
## {
##     "type": "scene_load_progress",
##     "progress": 0.73
## }
##
## This bus intentionally contains no logic.
## It only transports events between systems.
## ============================================================================
