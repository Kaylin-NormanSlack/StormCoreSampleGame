extends BaseEventBus
class_name GravityBus

# --------------------------------------------------
# Gravity Intent Signals
# --------------------------------------------------

##  {strength,direction (VECTOR2.UP/DOWN,transition_time}
signal gravity_changed(payload)
