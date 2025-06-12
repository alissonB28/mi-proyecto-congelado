extends Node3D

@onready var placa_izq = $placa_inferior
@onready var placa_der = $placa_superior
@onready var lbl_fuerza = $"../SubViewportContainer/Control/P_control/lbl_fuerza"
@onready var lbl_mensaje = $"../SubViewportContainer/Control/P_control/lbl_mensaje"
@onready var sl_distancia = $"../SubViewportContainer/Control/P_control/L_distancia/HSlider"
@onready var sl_ancho = $"../SubViewportContainer/Control/P_control/L_ancho/HSlider"
@onready var sl_modos = $"../SubViewportContainer/Control/P_control/L_modos/HSlider"
@onready var fuerza_flecha = $flecha
@onready var onda = $onda
@onready var popup = $"../SubViewportContainer/Control/PopupPanel"
@onready var titulo_pop = $"../SubViewportContainer/Control/PopupPanel/VBoxContainer/tituloExpl"
@onready var texto_pop = $"../SubViewportContainer/Control/PopupPanel/VBoxContainer/TextoExplicacion"

@onready var dialog  = $"../SubViewportContainer/Control/ConfirmationDialog"
@onready var input_dialog =$"../SubViewportContainer/Control/AcceptDialog"
@onready var comentario_input = $"../SubViewportContainer/Control/AcceptDialog/TextEdit"


const PI = 3.141592653589793
const HBAR = 1.0545718e-34
const C = 3.0e8
const SCALE_POS = 1e9  # 1 unidad Godot = 1 nanómetro

# Propiedades físicas
var plate_length_z := 1e-2
var plate_width_x := 1e-2
var plate_area := plate_length_z * plate_width_x
var mass := 1e-3
var current_velocity := 0.0
var force:= 0.0
var simulacion_finalizada := false


# Control de simulación
var simular := false
var vibration_time := 0.0
var current_distance := 0.0
var last_slider_value := 0.0
var initial_distance := 0.0

# Estabilidad
var damping := 0.95
var max_velocity := 1e-5
var min_distance_factor := 0.3
var results := {}

# Fase de vibración final
var vibrando := false
var tiempo_vibracion := 0.0
var duracion_vibracion := 2.0  # segundos

func _ready():
	popup.hide()
	simular = false
	# Conectar solo si no está ya conectado
	if not input_dialog.is_connected("confirmed", Callable(self, "_on_confirmar_guardado")):
		input_dialog.connect("confirmed", Callable(self, "_on_confirmar_guardado"))
	onda.set_slider(sl_modos)
	update_plate_width(sl_ancho.value)
	current_distance = sl_distancia.value / 1e9
	initial_distance = current_distance
	update_plate_positions_static(current_distance)
	lbl_mensaje.text = "Esperando a iniciar...."

func _on_b_iniciar_pressed():
	simular = true
	vibrando = false
	tiempo_vibracion = 0.0
	lbl_mensaje.text = " "
	sl_distancia.editable = false
	sl_ancho.editable = false
	sl_modos.editable = false
	current_velocity = 0.0
	initial_distance = current_distance

func casimir_force(area: float, distance: float) -> float:
	if distance <= 0.0:
		return 0.0
	var constant = -(PI * PI * HBAR * C) / 240.0
	return constant * area / pow(distance, 4)

func _process(delta):
	if not simular:
		if sl_distancia.value != last_slider_value:
			current_distance = sl_distancia.value / 1e9
			initial_distance = current_distance
			update_plate_positions_static(current_distance)
			last_slider_value = sl_distancia.value
		return

	vibration_time += delta
	force = casimir_force(plate_area, current_distance)
	var acceleration = abs(force) / mass

	if not vibrando:
		current_velocity += acceleration * delta
		current_velocity *= damping
		current_velocity = clamp(current_velocity, 0.0, max_velocity)

		var min_distance = initial_distance * min_distance_factor
		var new_distance = current_distance - current_velocity * delta

		current_distance = max(min_distance, new_distance)

		if current_distance == min_distance:
			current_velocity = 0.0
			vibrando = true
			tiempo_vibracion = 0.0
			lbl_mensaje.text = "Vibración final..."
			return
	else:
		tiempo_vibracion += delta
		if tiempo_vibracion >= duracion_vibracion:
			vibrando = false
			simular = false
			msm_explicacion()
			finalizar_simulacion()
			simulacion_finalizada = true
			sl_distancia.editable = true
			sl_ancho.editable = true
			sl_modos.editable = true
			return

	update_plate_positions(current_distance, force)
	update_label(force)
	update_wave_animation()
	
func msm_explicacion():
	lbl_mensaje.text = "Simulación finalizada:Distancia mínima."
	titulo_pop.text = "¿Qué ocurrió?"
	texto_pop.text = " La fuerza de Casimir, una fuerza cuántica que surge del 
				vacío entre dos placas metálicas muy cercanas,atrajo las placas 
				hasta que no pudieron acercarse más debido a una distancia mínima 
				establecida.\n
				Este fenómeno ilustra cómo incluso en el vacío aparente, las 
				fluctuaciones cuánticas del campo electromagnético producen 
				efectos físicos medibles sin necesidad de contacto directo."
	popup.position = Vector2(200,250)
	popup.popup()
		


func update_plate_positions(distance_m, force):
	var half_dist = distance_m * SCALE_POS * 0.5
	var vib_intensity = clamp(abs(force) * 1e7, 0.0, 0.5)
	var left_offset = sin(vibration_time * 0.5) * vib_intensity
	var right_offset = cos(vibration_time * 0.5) * vib_intensity

	placa_izq.transform.origin = Vector3(0, -half_dist + left_offset, 0)
	placa_der.transform.origin = Vector3(0, half_dist + right_offset, 0)

	onda.transform.origin = (placa_izq.transform.origin + placa_der.transform.origin) / 2.0

	fuerza_flecha.global_transform.origin = (placa_izq.global_transform.origin + placa_der.global_transform.origin) / 2.0
	safe_look_at(fuerza_flecha, placa_der.global_transform.origin)

func update_wave_animation():
	# Animación de onda basada en modos (frecuencia)
	var base_pos = (placa_izq.transform.origin + placa_der.transform.origin) / 2.0
	var amplitude = 0.1
	var freq = 1.0 + sl_modos.value
	var offset = sin(vibration_time * freq * 2.0 * PI) * amplitude

	onda.transform.origin.y = base_pos.y + offset

func update_plate_positions_static(distance_m):
	var half_dist = distance_m * SCALE_POS * 0.5
	placa_izq.transform.origin = Vector3(0, -half_dist, 0)
	placa_der.transform.origin = Vector3(0, half_dist, 0)

	fuerza_flecha.global_transform.origin = (placa_izq.global_transform.origin + placa_der.global_transform.origin) / 2.0
	safe_look_at(fuerza_flecha, placa_der.global_transform.origin)

	onda.transform.origin = (placa_izq.transform.origin + placa_der.transform.origin) / 2.0

func update_plate_width(slider_value: float):
	plate_width_x = slider_value / 100.0
	plate_area = plate_width_x * plate_length_z

	var scale_x = slider_value * 0.1
	placa_izq.scale.x = scale_x
	placa_der.scale.x = scale_x

func safe_look_at(node: Node3D, target_pos: Vector3, up_vector: Vector3 = Vector3.UP):
	var direction = (target_pos - node.global_transform.origin).normalized()
	if abs(direction.dot(up_vector)) > 0.999:
		up_vector = Vector3.FORWARD
	node.look_at(target_pos, up_vector)
	node.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90))

func reiniciar_simulacion():
	simulacion_finalizada = false
	simular = false
	vibrando = false
	tiempo_vibracion = 0.0
	vibration_time = 0.0
	current_velocity = 0.0
	current_distance = sl_distancia.value / 1e9
	initial_distance = current_distance
	update_plate_width(sl_ancho.value)
	update_plate_positions_static(current_distance)
	lbl_mensaje.text = "Nueva simulación..."
	lbl_fuerza.text = " "
	sl_distancia.value = 0
	sl_ancho.value = 0
	sl_modos.value = 0
	sl_distancia.editable = true
	sl_ancho.editable = true
	sl_modos.editable = true
	onda.transform.origin = (placa_izq.transform.origin + placa_der.transform.origin) / 2.0

func _on_b_parar_pressed():
	lbl_mensaje.text = "Simulación pausada"
	simular = false
	vibrando = false
	sl_distancia.editable = true
	sl_ancho.editable = true
	sl_modos.editable = true
	onda.transform.origin = (placa_izq.transform.origin + placa_der.transform.origin) / 2.0

func _on_b_nuevo_pressed():
	reiniciar_simulacion()

func update_label(force: float):
	lbl_fuerza.text = "Fuerza Casimir: " + str(force) + " N\nÁrea: " + str(plate_area) + " m²"

func _on_h_slider_value_changed(value: float) -> void:
	update_plate_width(value)
	current_distance = sl_distancia.value / 1e9
	initial_distance = current_distance
	update_plate_positions_static(current_distance)
	

func finalizar_simulacion():
	if not dialog.is_connected("confirmed", Callable(self, "_on_guardado_confirmado")):
		dialog.connect("confirmed", Callable(self, "_on_guardado_confirmado"))
	dialog.position = Vector2(950, 400)
	dialog.popup()


func _on_guardado_confirmado():
	input_dialog.position = Vector2(950,400)
	input_dialog.popup()

	
func _on_confirmar_guardado():
	var sim = SimulacionGuardada.new()
	sim.id_usuario = Global.id_usuario
	sim.titulo = "Efecto Casimir"
	sim.tiempo = Time.get_datetime_string_from_system().replace("T"," ")

	var parametros = {
		"distancia": sl_distancia.value,
		"ancho_placas": sl_ancho.value,
		"modos": sl_modos.value
	}
	sim.parametros = parametros

	var resultados = {
		"distancia_inicial": round(initial_distance * 1e9 * 100)/100.0,
		"distancia_final": str(round(current_distance * 1e9 * 100)/100.0),
		"Area": round(plate_area * 1e4 * 100) / 100.0,#pasarlo a cm2
		"fuerza_maxima": round(force * 1e9) / 1e9 
	}
	sim.resultados = resultados

	sim.descripcion = comentario_input.text
	comentario_input.text = ""
	results = resultados
	# Guardar en base de datos
	Database.guardar_simulacion_db(sim)
	print("Simulación guardada.")
	reiniciar_simulacion()
	simulacion_finalizada = true


func _on_b_resultados_pressed() -> void:
	popup.hide()
	texto_pop.text = ""
	texto_pop.custom_minimum_size = Vector2.ZERO  #
	if not simulacion_finalizada:
		lbl_mensaje.text = "Primero debes guardar la simulación."
		return
	titulo_pop.text = "Resultados:"
	var final = float(results["distancia_final"])
	var mensaje = "Distancia inicial: %.2f nm\n" % results["distancia_inicial"]
	mensaje += "Distancia final: %.2f nm\n" % final
	mensaje += "Área: %.2f cm²\n" % results["Area"]
	mensaje += "Fuerza Casimir: %.4f N\n" % results["fuerza_maxima"]

	 # Resetear el tamaño del popup para que se ajuste al contenido de resultados
	texto_pop.custom_minimum_size = Vector2.ZERO
	popup.size = Vector2.ZERO  # Fuerza el recálculo del tamaño
	texto_pop.text = mensaje
	popup.position = Vector2(800, 300)
	popup.popup()


func _on_b_guardar_pressed() -> void:
	if simulacion_finalizada:
		finalizar_simulacion()
	else:
		lbl_mensaje.text = "Primero debes finalizar una simulación."


func _on_confirmation_dialog_canceled() -> void:
	reiniciar_simulacion()
