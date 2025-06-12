extends Node3D

@export var rotation_speed := 0.01
@export var zoom_speed := 0.2
@export var min_distance := 1.0
@export var max_distance := 3.0

var angle_x := 0.0
var angle_y := PI
var distance := 1.9
var rotating := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Cámara configurada")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = max(min_distance, distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(max_distance, distance + zoom_speed)
	elif event is InputEventMouseMotion and rotating:
		angle_x -= event.relative.y * rotation_speed
		angle_y -= event.relative.x * rotation_speed
		angle_x = clamp(angle_x, -PI / 2, PI / 2)

func _process(_delta):
	var target = Vector3(0, 0, 0) # CENTRO ENTRE PLACAS
	var direction = Vector3(
		cos(angle_x) * sin(angle_y),
		sin(angle_x),
		cos(angle_x) * cos(angle_y)
	)
	position = target - direction * distance
	safe_look_at(self, target)

	
func safe_look_at(node: Node3D, target: Vector3, up_vector := Vector3.UP):
	var direction = (target - node.global_transform.origin).normalized()
	if abs(direction.dot(up_vector)) > 0.999:
		up_vector = Vector3.FORWARD  # Vector alternativo si están alineados
	node.look_at(target, up_vector)
