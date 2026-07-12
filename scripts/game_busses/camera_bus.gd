extends BaseEventBus
class_name CameraBus

# --------------------------------------------------
# Camera Intent Signals
# --------------------------------------------------

## Request the camera to focus on a specific target
## payload: { target: Node2D, duration?: float }
signal camera_focus_requested(payload: Dictionary)

## Request a camera pan between two positions
## payload: { from: Vector2, to: Vector2, durati w sdon: float }
signal camera_pan_requested(payload: Dictionary)

## Request a camera shake effect
## payload: { intensity: float, duration: float }
signal camera_shake_requested(payload: Dictionary)

## Lock camera movement (cutscenes, puzzles, etc.)
signal camera_lock_requested

## Release camera lock and resume normal behavior
signal camera_release_requested

## Change camera behavior mode
## payload: { mode: String }
signal camera_mode_changed(payload: Dictionary)

signal camera_velocity_changed(payload: Dictionary)
