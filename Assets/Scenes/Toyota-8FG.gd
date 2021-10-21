extends Spatial

#User interface script variable.
var ui_script

#Engine Variables


#Electrical
#↓Master_Ignition.
var master_ignition = false



#AnimationPlayers.
onready var animation_player = get_node("AnimationPlayer")
#First Hydraulic Valve.
onready var hyd1_animation_player = get_node("AnimationPlayer_Hydraulic_Valve_First")
#Second Hydraulic Valve.
onready var hyd2_animation_player = get_node("AnimationPlayer_Hydraulic_Valve_Second")
#Third Hydraulic Valve.
onready var hyd3_animation_player = get_node("AnimationPlayer_Hydraulic_Valve_Third")



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
	hyd2_animation_player.set_current_animation("Second_Hydralic_Valve_Animation")
	hyd2_animation_player.seek(1.7,true)
	hyd2_animation_player.stop(false)
	
	#Third Hydraulic Lever.
	hyd3_animation_player.set_current_animation("Third_Hydraulic_Valve_Animation")
	hyd3_animation_player.seek(1.7,true)
	hyd3_animation_player.stop(false)



# Called when the node enters the scene tree for the first time.
func _ready():
	#Init vehicle animations to their halfway / rest positions.
	init_animations()
	#Get node, that the Ui script is attached to, so we can call the script from here.
	ui_script = get_node("User-Interface/Root-Control")



#For now, we will use unhandled input for vehicle controls.
#As i believe it will give more flexibility, for per vehicle custom re-assignable inputs. 
func _unhandled_input(event):
	if event is InputEventKey:
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
