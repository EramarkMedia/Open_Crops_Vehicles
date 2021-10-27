extends Control

#Timer for handling delays between dot animations. "Constant value."
var dot_timer 
#Random init "time" timer, runs in process when active.
var passed_time = 0
#Smartscreen Audioplayer.
onready var screen_sound = get_node("./Smartscreen_Frame/Screen_AudioStreamPlayer")
#Timer for handling screen value updates.
var element_timer

#Itemlist.
onready var list = get_node("KeyBindingsItemList")
#Keybind grabbing state variable. For disabling all other input when we want to grab inputs.
var grab_input = false

var grabbed_input

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	#Call function for populating keybind list.
	populate_keybind_list()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	passed_time +=delta

#Function for populating the keybind list.
func populate_keybind_list():
	#Set the header for engine category, assign icon for category, and set as non-selectable "OBS,Huom,Note!***Bug***."Will remain selectable"
	list.add_item("Engine",load("res://Assets/Ui/Keybinding_Category_Icons/Engine.png"),false)
	#Add master ignition to list, as selectable.
	list.add_item("Master-Ignition",null,true)

#Called when keybind grab window becomes visible.
#Here we will set grab_input variable to true, so we can check the state of that var in unhandled input over at Toyota-8GD.gd
func Keybind_Grab_WindowDialog_draw():
	grab_input = true

#Called when keybind grab window becomes hidden.
#Here we will set grab_input variable to false, so we can check the state of that var in unhandled input over at Toyota-8GD.gd
func Keybind_Grab_WindowDialog_hide():
	grab_input = false

#Function for itemlist selections. #Use rmb selection, in order for user to be able to highlight with lmb.
func KeyBindingsItemList_item_rmb_selected(index, _at_position):
	#Show windowdialog for grabbing / assigning input. "in center of screen"
	get_node("./Keybind_Grab_WindowDialog").popup_centered()
	#Get selected index of list in text.
	var item = list.get_item_text(index)
	#Get & assign the label of the input we have selected in list.
	get_node("./Keybind_Grab_WindowDialog/Keybind_Source_Label").bbcode_text = "[center]"+item+"[/center]"
	print(item)

#Function for handling visibility of keybind list.
func toggle_keybind_list():
	var list_visible = $"./KeyBindingsItemList".is_visible()
	if !list_visible:
		$"./KeyBindingsItemList".show()
	else:$"./KeyBindingsItemList".hide()

#Called from Toyota-8FG.gd
func init_smartscreen(var state):
	#If we want to turn the screen on.
	if state == "on":
		#Set visibility of animated dots to zero.
		get_node("Smartscreen_Frame/Screen/Screen_Init_Text/Animated_Dots").set_visible_characters(0)
		dot_timer = Timer.new()
		#Connect timer to draw dots function.
		dot_timer.connect("timeout",self,"draw_dots")
		#Add the timer as child.
		add_child(dot_timer)
		dot_timer.start(0.8)
		
		#Change the color of our background panel, to light orange. "On"
		get_node("./Smartscreen_Frame/Screen").get_stylebox("panel").set_bg_color(Color(0.8,0.51,0,0.7))
		#Set init beep as the current track.
		screen_sound.stream = load("res://Assets/Ui/Smart_Screen/Sounds/Init_Beep.wav")
		#Play init beep.
		screen_sound.play(0)
		#Get the init text label, and change it to Initializing.
		get_node("./Smartscreen_Frame/Screen/Screen_Init_Text").bbcode_text = "[center]"+"Initializing"+"[/center]"
		#Display init text label. "for the sake of visuals"
		get_node("./Smartscreen_Frame/Screen/Screen_Init_Text").show()
		

	else:
		#If we want to turn the screen of.
		#Change the color of our background panel, to dark grey. "Off"
		get_node("./Smartscreen_Frame/Screen").get_stylebox("panel").set_bg_color(Color(0.18,0.18,0.18,1))
		#Check if we are playing, before trying to stop.
		if screen_sound.playing:
			screen_sound.stop()
		#Hide init text label. "for the sake of visuals"
		get_node("./Smartscreen_Frame/Screen/Screen_Init_Text").hide()
		#Check if the dot animation timer is still valid / exists, before trying to stop & destroy it.
		#Prevents error, of trying to handle if unavailable. 
		var dot_timer_status = is_instance_valid(dot_timer)
		if dot_timer_status:
			dot_timer.stop()
			dot_timer.queue_free()
		#Stop processing, as we dont need passed time anymore.
		set_process(false)
		var element_timer_status = is_instance_valid(element_timer)
		if element_timer_status:
			element_timer.stop()
			element_timer.queue_free()
		#Since we are shutting the screen off, hide screen elements.
		get_node("./Smartscreen_Frame/Screen/Screen_Elements_Master").hide()

func draw_dots():
	#Set processing to true, so we can grab elapsed time, some other way, than by creating another timer.
	set_process(true)
	#Generate random init time value to check, between 3-12seconds.
	var init_time_limit = rand_range(3,12)
	#Get the dots, that we are supposed to "animate"
	var dots = get_node("Smartscreen_Frame/Screen/Screen_Init_Text/Animated_Dots")
	#Check how many of the dots are visible.
	var visibilitylevel = dots.get_visible_characters()
	#check if we are showing less than 3 dots "Which we are supposed to do, to solve this like this.
	if visibilitylevel <3:
		#Add one unit of visibility, for every time we pass.
		dots.set_visible_characters(visibilitylevel+1)
		#When we are at maximum dots, reset visibility, and start over.
	elif visibilitylevel == 3:
		dots.set_visible_characters(0)
		#Check if we have passed our random init time, if true, stop the timer, and destroy it.
	if passed_time > init_time_limit:
		dot_timer.stop()
		dot_timer.queue_free()
		#Stop processing, as we dont need passed time anymore.
		set_process(false)
		#Re-set passed time.
		passed_time = 0
		start_smartscreen()

func start_smartscreen():
	#Hide the initialization text, since we are starting up the screen.
	get_node("./Smartscreen_Frame/Screen/Screen_Init_Text").hide()
	#Display the main screen elements of the first page of the screen.
	get_node("./Smartscreen_Frame/Screen/Screen_Elements_Master").show()
	#Create timer for updating screen element values.
	element_timer = Timer.new()
	#Connect screen element timer.
	element_timer.connect("timeout",self,"update_elements")
	#Add element timer as child.
	add_child(element_timer)
	#Start element update with 0.5sec poll. "More than enough for screen elements".
	element_timer.start(0.5)


func update_elements():
	#Here we shall grab info from the variables in the main vehicle script.
	print("update")
	pass



#Button Events.

func _on_Speed_Selection_Button_pressed():
	#Should check if master ignition is on, before playing....
	screen_sound.stream = load("res://Assets/Ui/Smart_Screen/Sounds/Button_Beep.wav")
	screen_sound.play(0)






