extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_LEFT:
			# This is wrong, but just for testing...
			get_node("Rear/SteeringLink/SteeringPiston").apply_impulse(Vector3.ZERO, get_node("Rear/SteeringLink/SteeringPiston").transform.basis.x * 1.0)
		elif event.pressed and event.scancode == KEY_RIGHT:
			get_node("Rear/SteeringLink/SteeringPiston").apply_impulse(Vector3.ZERO, -get_node("Rear/SteeringLink/SteeringPiston").transform.basis.x * 1.0)
