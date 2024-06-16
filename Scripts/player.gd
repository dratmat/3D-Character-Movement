extends CharacterBody3D

# Constants for movement speed and jump velocity
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Exported variables for mouse sensitivity
@export var sens_horizontal = 0.3
@export var sens_vertical = 0.3

# Minimum and maximum angles for camera pitch (looking up and down)
@export var min_pitch = -90.0
@export var max_pitch = 90.0

# Onready variables to cache node references
@onready var camera_mount = $"Camera Mount"

# Get the gravity setting from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Variables for camera rotation
var rotation_degrees_y = 0.0
var pitch = 0.0

func _ready():
	# Set mouse mode to captured (locked and invisible)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# Handle camera movement based on mouse motion only if the mouse is captured
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# Rotate horizontally
			rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))  
			
			# Adjust pitch and clamp it
			pitch -= event.relative.y * sens_vertical
			pitch = clamp(pitch, min_pitch, max_pitch)
			camera_mount.rotation_degrees.x = pitch

func _physics_process(delta):
	# Apply gravity when the character is not on the floor
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Toggle mouse mode between visible and captured when the cancel action (usually ESC) is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Get the input direction vector based on movement actions (left, right, forward, back)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var strafe_direction = transform.basis.x * input_dir.x
	var forward_direction = camera_mount.global_transform.basis.z * input_dir.y  # Change direction to match correct forward movement

	# Calculate the velocity based on input
	velocity.x = (strafe_direction.x + forward_direction.x) * SPEED
	velocity.z = (strafe_direction.z + forward_direction.z) * SPEED

	# Apply movement and handle sliding on slopes
	move_and_slide()
