extends Spatial

onready var hinge_joint = $MainRigidBody/Pivot
export(float) var angle_force = .1
export(float) var height_force = .4
export(float) var pivot_range = 5
export(float) var height_range = .5

var default_height

# Called when the node enters the scene tree for the first time.
func _ready():
	default_height = hinge_joint.translation.y

func _process(delta):
	var angle_vel = 0
	if Input.is_action_pressed("angle_up"):
		angle_vel += angle_force
	if Input.is_action_pressed("angle_down"):
		angle_vel -= angle_force
		
	hinge_joint.rotate_x(angle_vel*delta)
	hinge_joint.rotation_degrees.x = clamp(hinge_joint.rotation_degrees.x, -pivot_range, pivot_range)
		
	var height_vel = 0
	if Input.is_action_pressed("height_up"):
		height_vel += height_force
	if Input.is_action_pressed("height_down"):
		height_vel -= height_force

	hinge_joint.translation.y += height_vel*delta
	hinge_joint.translation.y = clamp(hinge_joint.translation.y, default_height, default_height+height_range)
