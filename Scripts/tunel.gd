extends Node3D

@onready var escena_particula = preload("res://Scenes/particula.tscn")
@onready var barrera = $StaticBody3D
@onready var label_energia = $"../../Control/P_control/L_energia/tag_e"
@onready var label_ancho = $"../../Control/P_control/L_ancho/tag_a"
@onready var label_particulas = $"../../Control/P_control/L_particulas/tag_m"
@onready var label_transferencia = $"../../Control/P_control/Label_transferencia"
@onready var label_tiempo = $"../../Control/P_control/L_tiempo"
@onready var slider_energia = $"../../Control/P_control/L_energia/HSlider"
@onready var slider_ancho = $"../../Control/P_control/L_ancho/HSlider"
@onready var slider_particulas = $"../../Control/P_control/L_particulas/HSlider"

@onready var popup_explicacion = $"../../Control/PopupPanel"
@onready var texto_explicacion = $"../../Control/PopupPanel/VBoxContainer/TextoExplicacion"
@onready var titulo_expl = $"../../Control/PopupPanel/VBoxContainer/tituloExpl"
@onready var partin = $RigidBody3D
@onready var anim = $"../../AnimationPlayer"
@onready var lbl_mensaje =$"../../Control/P_control/lbl_mensaje"

@onready var dialog  = $"../../Control/ConfirmationDialog"
@onready var input_dialog =$"../../Control/AcceptDialog"
@onready var comentario_input = $"../../Control/AcceptDialog/TextEdit"

var velocidad = 2.0
var energia_particula = 1.0
var ancho_barrera = 1.0
var particulas = 1.0


var total_particulas = 0
var conteo_atraviesan = 0
var conteo_rebotan = 0
var tiempo = 0.0
var simulacion_activa = false
var simulacion_finalizada = false
var results := {}
var total := {}

var amplitud_onda = 1.0
var longitud_onda = 1.0
var frecuencia = 1.0
var distancia_interferencia = 3.0
var particulas_creadas = false
var velocidades_guardadas := {}
var simulacion_pausada = false




func _ready():
	partin.freeze = true
	randomize()
	set_notify_transform(true)
	# Conectar solo si no está ya conectado
	if not input_dialog.is_connected("confirmed", Callable(self, "_on_confirmar_guardado")):
		input_dialog.connect("confirmed", Callable(self, "_on_confirmar_guardado"))
		


func _on_b_iniciar_pressed() -> void:
	lbl_mensaje.text= " "
	if simulacion_pausada:
		simulacion_pausada = false
		simulacion_activa = true
		partin.freeze = false
		for child in get_children():
			if child.name.begins_with("Particula") and child is RigidBody3D:
				child.freeze = false
				if child.name in velocidades_guardadas:
					child.linear_velocity = velocidades_guardadas[child.name]
		lbl_mensaje.text = "Simulación reanudada"
		return
	# Si no está pausada, iniciar una simulación nueva
	partin.freeze = false
	partin.visible = false
	anim.stop()
	energia_particula = slider_energia.value
	ancho_barrera = slider_ancho.value
	total_particulas = int(slider_particulas.value)

	for i in range(total_particulas):
		var nueva_particula = escena_particula.instantiate()
		nueva_particula.position = Vector3(-1, 0.1 * i, 0)
		nueva_particula.freeze = false
		nueva_particula.linear_velocity = Vector3(velocidad, 0, 0)
		nueva_particula.energia = energia_particula
		nueva_particula.ancho_barrera = ancho_barrera
		nueva_particula.posicion_barrera = barrera.global_position.x
		nueva_particula.callback_node = self
		add_child(nueva_particula)
		nueva_particula.name = "Particula_%d" % i
	slider_ancho.editable = false
	slider_energia.editable = false
	slider_particulas.editable = false
	simulacion_activa = true

	
	
func _process(delta):
	if not simulacion_activa:
		return

	tiempo += delta
	barrera.scale.x = ancho_barrera
	label_tiempo.text = "Tiempo: %2.f" % tiempo

	if conteo_atraviesan + conteo_rebotan < total_particulas:
		var posicion_demo = generar_interferencia(tiempo)
		label_transferencia.text = "Interferencia: %.2f" % posicion_demo
	else:
		simulacion_activa = false
		await get_tree().create_timer(1.9).timeout
		msm_explicacion()
		finalizar_simulacion()
		simulacion_finalizada = true


	

func generar_interferencia(t):
	var onda1 = amplitud_onda * sin(2 * PI * frecuencia * t)
	var onda2 = amplitud_onda * sin(2 * PI * frecuencia * t - distancia_interferencia / longitud_onda)
	return onda1 + onda2


func reiniciar_simulacion():
	slider_energia.value = 0
	slider_ancho.value =0
	slider_particulas.value = 0 
	
	popup_explicacion.hide()
	particulas_creadas = false
	for child in get_children():
		if child.name.begins_with("Particula") and child is RigidBody3D:
			child.queue_free()

	partin.visible = true
	partin.freeze = true
	partin.global_position = Vector3(-1, 0, 0)
	partin.linear_velocity = Vector3.ZERO
	partin.angular_velocity = Vector3.ZERO

	ancho_barrera = slider_ancho.value
	barrera.scale.x = ancho_barrera
	
	conteo_atraviesan = 0
	conteo_rebotan = 0
	tiempo = 0.0
	simulacion_activa = false
	simulacion_finalizada = false
	particulas_creadas = false
	slider_ancho.editable = true
	slider_energia.editable = true
	slider_particulas.editable = true
	label_transferencia.text =""
	label_tiempo.text = ""
	lbl_mensaje.text = "Nueva simulación.. "

func _on_b_parar_pressed() -> void:
	if not simulacion_activa:
		return

	partin.freeze = true
	simulacion_activa = false
	simulacion_pausada = true
	velocidades_guardadas.clear()

	for child in get_children():
		if child.name.begins_with("Particula") and child is RigidBody3D:
			velocidades_guardadas[child.name] = child.linear_velocity
			child.freeze = true
			child.linear_velocity = Vector3.ZERO

	lbl_mensaje.text = "Simulación pausada"

func notificar_resultado(paso: bool):
	if paso:
		conteo_atraviesan += 1
	else:
		conteo_rebotan += 1

func mostrar_resultado_final():
	popup_explicacion.hide()
	texto_explicacion.text = ""
	texto_explicacion.custom_minimum_size = Vector2.ZERO
	popup_explicacion.size = Vector2.ZERO
	titulo_expl.text = "Resultado final:"
	var reb = results.get("rebotaron",0)
	var atr = results.get("atravesaron",0)
	var tot = atr + reb
	var mensaje = "Total: %d\n" % tot
	mensaje += "Atravesaron: %d\n" % atr
	mensaje += "Rebotaron: %d\n" % reb

	texto_explicacion.text = mensaje
	popup_explicacion.popup_centered()


func msm_explicacion():
	lbl_mensaje.text = "Simulación finalizada"
	titulo_expl.text = "¿Qué ocurrió?"
	if conteo_atraviesan > 0:
		texto_explicacion.text = " Algunas partículas atravesaron la barrera debido al efecto túnel 
		cuántico. Su naturaleza ondulatoria les permite tener una 
		pequeña probabilidad de estar al otro lado, incluso sin energía suficiente 
		según la física clásica."
		popup_explicacion.position = Vector2(200,250)
		popup_explicacion.popup()
	else : 
		texto_explicacion.text = " Las partículas que rebotaron no lograron superar la barrera.
		Aunque en mecánica cuántica existe una probabilidad de túnel,
		esta disminuye con barreras más anchas o energías más bajas.
		¡Sigue intentando con más particulas!"
		popup_explicacion.position = Vector2(200,250)
		popup_explicacion.popup()

func _on_b_nuevo_pressed() -> void:
	reiniciar_simulacion()

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
	sim.titulo = "Túnel Cuántico"
	sim.tiempo = Time.get_datetime_string_from_system().replace("T"," ")

	var parametros = {
		"energia": energia_particula,
		"ancho_barrera": ancho_barrera,
		"total_particulas": total_particulas
	}
	sim.parametros = parametros

	var resultados = {
		"atravesaron": conteo_atraviesan,
		"rebotaron": conteo_rebotan,
		"tiempo": tiempo,
		"interferencia": label_transferencia.text
	}
	sim.resultados = resultados

	sim.descripcion = comentario_input.text
	comentario_input.text = ""
	results = resultados
	total = parametros
	# Guardar en base de datos
	Database.guardar_simulacion_db(sim)
	lbl_mensaje.text = "Simulación guardada."
	reiniciar_simulacion()
	simulacion_finalizada = true

	
	
func _on_b_guardar_pressed() -> void:
	if 	simulacion_finalizada:
		finalizar_simulacion()
	else: 
		lbl_mensaje.text = "Primero debes finalzar una simulación."
		


func _on_b_resultados_pressed() -> void:
	if 	simulacion_finalizada:
		mostrar_resultado_final()
	else: 
		lbl_mensaje.text = "Primero debes guardar la simulación."


func _on_confirmation_dialog_canceled() -> void:
	simulacion_finalizada = false
	slider_ancho.editable = true
	slider_energia.editable = true
	slider_particulas.editable = true
	lbl_mensaje.text = "Guardado cancelado\nPuedes ajustar los parámetros."
