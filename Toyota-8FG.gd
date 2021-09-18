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
			get_node("Rear_Wheel_Right_Joint").set("angular_motor_y/target_velocity", 2)
			get_node("Rear_Wheel_Left_Joint").set("angular_motor_y/target_velocity", 2)
		elif event.pressed and event.scancode == KEY_RIGHT:
			get_node("Rear_Wheel_Right_Joint").set("angular_motor_y/target_velocity", -2)
			get_node("Rear_Wheel_Left_Joint").set("angular_motor_y/target_velocity", -2)
		#else: get_node("Rear_Wheel_Right_Joint").set("angular_motor_y/target_velocity", 0)
		#get_node("Rear_Wheel_Left_Joint").set("angular_motor_y/target_velocity", 0)  
