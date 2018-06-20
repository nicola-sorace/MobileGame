extends RigidBody2D

var speed = 5
#var gravity = 4000000
var stiffness = 100
var torque = 100

var colors = [Color(1,1,1), Color(1,0,0), Color(0,1,0), Color(0,0,1)]

var maxJumps = 1
var jumps = maxJumps
var jump = 200

var power = 0

var action_down = false

onready var cam = get_node("../Camera2D")
onready var hud = get_node("../HUD")
onready var joystick = hud.get_node("Joystick")
onready var sprite = get_node("Sprite")
onready var light = get_node("Light")

var rocket = preload("res://objects/Rocket.tscn")

func _integrate_forces(state):
	
	for c in state.get_contact_count():
		if state.get_contact_local_normal(c).y < -0.5 and linear_velocity.y>-6:
			jumps = maxJumps
	
	var d = (Vector2(int(Input.is_action_pressed("Right"))-int(Input.is_action_pressed("Left")), int(Input.is_action_pressed("Down"))-int(Input.is_action_pressed("Up"))) + joystick.v).normalized()
	
	# Movement
	var m = d * speed
	if not(power==1 and action_down): apply_impulse(Vector2(0,0), m)
	
	# Stiffness
	var t
	if (power==3 or power==1) and action_down:  #Slide power
		t = 0
		if power==3:
			set_friction(0)
	else:
		t = torque*(-d.x)
		set_friction(1)
	
	apply_torque(stiffness * sin(get_rotation()*4) + t)
	
	if power==2 and action_down:  #Weight power
		set_mass(20)
	else:
		set_mass(1)
	
	# Planetary Gravity
	"""
	for p in get_tree().get_nodes_in_group("planet"):
		var r = p.get_global_transform().origin - get_global_transform().origin
		add_force(Vector2(0,0), r.normalized() * gravity/pow(r.length(),3))
	"""
	
	# Keyboard controls
	if Input.is_action_just_pressed("Action"): action_pressed()
	if Input.is_action_just_released("Action"): action_released()
	
	cam.set_offset(get_global_transform().origin)
	update_power()

func apply_torque(t):
	apply_impulse(Vector2(0,1), Vector2(1,0) * t)
	apply_impulse(Vector2(0,-1), Vector2(-1,0) * t)

func update_power():
	var r = get_rotation_degrees()
	
	var n
	if r>-45 and r<=45: n=0
	elif r>45 and r<=135: n=1
	elif r>135 or r<=-135: n=2
	elif r>-135 and r<=-45: n=3
	if n != power:
		power = n
		sprite.power = n
		light.set_color(colors[n])
		#print("Switched to mode: " + str(n))

func action_pressed():
	action_down = true
	if power==0:  #Jump power
		if jumps>0:
			jumps = jumps-1
			apply_impulse(Vector2(0,0), Vector2(0,-jump))

func action_released():
	action_down = false
	
	if power == 1:
		var tmp = rocket.instance()
		tmp.setup(self, joystick.v)
		get_parent().add_child_below_node(self, tmp) #TODO display below player