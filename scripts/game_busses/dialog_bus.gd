extends BaseEventBus
class_name DialogBus
## StormCore bus for dialogue-related requests and events.

signal dialogue_started(timeline_path: String)
signal dialogue_ended

## Raw event forwarded from a dialogue provider such as Dialogic.
signal dialogue_event_received(event_name: String)

## More specific game-facing dialogue events.
signal scene_transition_requested(scene_path: String)
signal game_event_requested(event_name: String)
