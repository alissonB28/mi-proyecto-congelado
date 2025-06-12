extends MeshInstance3D

const AMPLITUDE := 0.2
const WAVELENGTH := 1.0
const SPEED := 1.2
const POINTS := 100
const LENGTH := 2.5

var phase := 0.0
var im_mesh := ImmediateMesh.new()
var current_mode := 0

func _ready():
	mesh = im_mesh
	update_wave()

func _process(delta):
	phase += delta * SPEED
	update_wave()

# Función para asignar el slider de modos, conectar señal y guardar modo actual
func set_slider(slider):
	current_mode = int(slider.value)
	slider.connect("value_changed", Callable(self, "_on_mode_changed"))
	update_wave()

func _on_mode_changed(value):
	current_mode = int(value)
	update_wave()

func update_wave():
	im_mesh.clear_surfaces()
	im_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)

	for i in range(POINTS):
		var x = LENGTH * i / (POINTS - 1)
		var y = sin(x * TAU / WAVELENGTH + phase) * AMPLITUDE
		var point = Vector3(x - LENGTH / 2.0, y, 0)
		im_mesh.surface_add_vertex(point)

	im_mesh.surface_end()

	var mat = StandardMaterial3D.new()
	mat.albedo_color = get_color_for_mode()
	material_override = mat
	
func get_color_for_mode() -> Color:
	if current_mode <= 2:
		return Color(0, 0.486, 0.715)  # Azul
	elif current_mode <= 5:
		return Color(0, 1, 0)          # Verde
	elif current_mode <= 8:
		return Color(1, 0.65, 0)       # Naranja
	else:
		return Color(1, 0, 0)          # Rojo
