extends Spatial


#User interface script variable.
var ui_script

#Engine Variables

#Vehicle Control.
var steering_speed = 5
var steering_target: float

#Wheel Joints.
#Front
onready var Right_Front_Joint = $"Wheel_Front_Right/Wheel_Front_Right_Joint"
onready var Left_Front_Joint = $"Wheel_Front_Left/Wheel_Front_Left_Joint"
#Rear
onready var Right_Rear_Joint = $"Rear_Axle/Wheel_Rear_Right_Joint"
onready var Left_Rear_Joint = $"Rear_Axle/Wheel_Rear_Left_Joint"

#Electrical
#↓Master_Ignition.
var master_ignition = false

#Mouse events.
enum INPUT_STATE { LEFT, SHIFT_LEFT, CTRL_LEFT, RIGHT, NONE }
var input_state : int = INPUT_STATE.NONE

#AnimationPlayers.
onready var animation_player = get_node("AnimationPlayer")
#First Hydraulic Valve.
onready var hyd1_animation_player = get_node("AnimationPlayer_Hydraulic_Valve_First")
#Second Hydraulic Valve.
onready var hyd2_animation_player = get_node("AnimationPlayer_Hydraulic_Valve_Second")
#Third Hydraulic Valve.
onready var hyd3_animation_player = get_node("AnimationPlayer_Hydraulic_Valve_Third")


#Views "Experimental"
var cycles = 0
onready var cam1 := $"8-FG_Body/Chassie/Camera_Internal_Position_Locator/Cab_Camera"
onready var cam2 := $"8-FG_Body/Chassie/Outside_Cam_Rot_Point/Outside_Camera"

#Camera ↓ ------------------------------#
onready var camera_ref : Spatial = $"8-FG_Body/Chassie/Camera_Internal_Position_Locator"

const rotation_scale : float = 1.0/100.0
const pan_scale : float = 1.0/100.0
const camera_z_min : float = -0.250
const camera_z_max : float = 0.095

var camera_x : float = 0
var camera_y : float = 0
var camera_z : float = 0

var camera_offset : Vector3 = Vector3()
#---------------------------------------#



#Function for setting vehicle animations to correct positions.
#Most of the animations need to run from halfway, both forward and backwards, for different purposes.
func init_animations():
	#Heading Selector, Turn Indication, and Ignition_Key will share the same animationplayer, since it is very unlikely they would need to be separated.
	#Heading Selector.
	#Set the current animation to Heading_Selector.
	animation_player.set_current_animation("Heading_Selector_Animation")
	#Seek our way to the time when heading selector lever is in centered idle state. .seek() function requires the animation to be playing when called.
	#However, calling set_current_animation does also play().
	animation_player.seek(2.5,true)
	#Stop the animation, at correct position. And don't reset.
	animation_player.stop(false)
	
	#Turn Signal Lever.
	#Set the current animation to Turn_Indicator.
	animation_player.set_current_animation("Turn_Indicator_Animation")
	#Seek our way to the time when turn indication lever is in centered idle state. .seek() function requires the animation to be playing when called.
	#However, calling set_current_animation does also play().
	animation_player.seek(0.8,true)
	#Stop the animation, at correct position. And don't reset.
	animation_player.stop(false)
	
	
	#First Hydraulic Lever.
	hyd1_animation_player.set_current_animation("First_Hydraulic_Valve_Animation")
	
	hyd1_animation_player.seek(1.7,true)
	hyd1_animation_player.stop(false)
	
	#Second Hydraulic Lever.
	hyd2_animation_player.set_current_animation("Second_Hydraulic_Valve_Animation")
	hyd2_animation_player.seek(1.7,true)
	hyd2_animation_player.stop(false)
	
	#Third Hydraulic Lever.
	hyd3_animation_player.set_current_animation("Third_Hydraulic_Valve_Animation")
	hyd3_animation_player.seek(1.7,true)
	hyd3_animation_player.stop(false)

#Highly Experimental. 
func cycle_views():
	if cycles == 0:
		cycles = cycles + 1
		cam1.make_current()
	else:
		cam2.make_current()
		cycles = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#Init vehicle animations to their halfway / rest positions.
	init_animations()
	#Get node, that the Ui script is attached to, so we can call the script from here.
	ui_script = get_node("User-Interface/Root-Control")



#For now, we will use unhandled input for vehicle controls.
#As i believe it will give more flexibility, for per vehicle custom re-assignable inputs. 
func _unhandled_input(event):
	#Key Events.
	if event is InputEventKey:
		print("key")
		if ui_script.grab_input == false:
			#print("false")
			#Keybind list will atleast for now, remain hardcoded to key F1.
			if event.pressed and event.scancode == KEY_F1:
				ui_script.toggle_keybind_list()

			#Experimental.
			if event.pressed and event.scancode == KEY_B:
				cycle_views()

			#Experimental.
			if event.pressed and event.scancode == KEY_LEFT:
				if $"8-FG_Body/Chassie/Dashboard/Steering_Wheel".rotation_degrees.z > -720:
					steering_target = steering_target + 0.1
					Steer(steering_target)

			if event.pressed and event.scancode == KEY_RIGHT:
				if $"8-FG_Body/Chassie/Dashboard/Steering_Wheel".rotation_degrees.z < 720:
					steering_target = steering_target - 0.1
					Steer(steering_target)



			if event.pressed and event.scancode == KEY_I:
				if master_ignition == false:
					#Set master ignition on "Handles master electrics.
					master_ignition = true
					#Call Ui script init_smartscreen fuction, to turn monitor on.
					ui_script.init_smartscreen("on")
				else:
					#Set master ignition off "Handles master electrics.
					master_ignition = false
					#Call Ui script init_smartscreen fuction, to turn monitor off.
					ui_script.init_smartscreen("off")


		else: 
			ui_script.grabbed_input = event.as_text()
			print(ui_script.grabbed_input)

	#Mouse Events.
	elif event is InputEventMouseButton:
		var mouse_event : InputEventMouseButton = event
		if (not event.pressed) && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT):
			input_state = INPUT_STATE.NONE
		elif (mouse_event.button_index == BUTTON_LEFT):
			if mouse_event.shift:
				input_state = INPUT_STATE.SHIFT_LEFT
			elif mouse_event.control:
				input_state = INPUT_STATE.CTRL_LEFT
			else:
				input_state = INPUT_STATE.LEFT
		elif mouse_event.button_index == BUTTON_RIGHT:
			input_state = INPUT_STATE.RIGHT
		elif (mouse_event.button_index == BUTTON_WHEEL_UP):
			camera_z = clamp(camera_z - 0.01, camera_z_min, camera_z_max)
			camera_ref.translation.z = camera_z
		elif (mouse_event.button_index == BUTTON_WHEEL_DOWN):
			camera_z = clamp(camera_z + 0.01, camera_z_min, camera_z_max)
			camera_ref.translation.z = camera_z
	
	elif (event is InputEventMouseMotion):
		var mouse_event : InputEventMouseMotion = event
		match input_state:
			INPUT_STATE.NONE:
				camera_x += mouse_event.relative.x * rotation_scale
				camera_y -= mouse_event.relative.y * rotation_scale
				camera_y = clamp(camera_y, -PI/2, PI/2)
				camera_ref.transform.basis = Basis().rotated(Vector3.LEFT, -camera_y).rotated(Vector3.UP, -camera_x)
			INPUT_STATE.SHIFT_LEFT:
				print("Shift+Left")




func Steer(Amount):
	#print(Amount)
	var angle = 0.523599 # 30 degrees

	if Amount < 0.1 and Amount > -0.1:
		#print("no steer")

		Right_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_LOWER_LIMIT, 0)
		Right_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_UPPER_LIMIT, 0)

		Left_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_LOWER_LIMIT, 0)
		Left_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_UPPER_LIMIT, 0)

	else:
		#print("steer")

		if Amount > 0:
			Right_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_UPPER_LIMIT, angle * Amount / 6)
			Left_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_UPPER_LIMIT, angle * Amount / 6)
		else:
			Right_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_LOWER_LIMIT, angle * Amount / 6)
			Left_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_LOWER_LIMIT, angle * Amount / 6)

		Right_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * 50)
		Left_Rear_Joint.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * 50)



func _physics_process(delta):
	#Control Steering Wheel Motion.
	$"8-FG_Body/Chassie/Dashboard/Steering_Wheel".rotation.z = lerp_angle($"8-FG_Body/Chassie/Dashboard/Steering_Wheel".rotation.z,-steering_target,1.0)
	
	#Debug Label.
	$"User-Interface/Root-Control/Debug_Label".text = "Wheel Transform:" + String($"8-FG_Body/Chassie/Dashboard/Steering_Wheel".rotation_degrees.z)



