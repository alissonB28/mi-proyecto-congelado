extends Control

@onready var titulo_l = $titulo/Label_usuario  
@onready var nombre_l = $P_datos/L_nombre/P_nombre/nombre_usuario
@onready var correo_l = $P_datos/L_correo/P_correo/correo_usuario
@onready var contenedor_simulaciones = $P_simulaciones/ScrollContainer/HistorialVBox

@onready var label_titulo = $P_estadisticas/HBoxContainer/Control2/Estadis/l_titulo
@onready var label_ID = $P_estadisticas/HBoxContainer/Control2/Estadis/l_ID
@onready var label_Des = $P_estadisticas/HBoxContainer/Control2/Estadis/desc/l_des
@onready var label_E =$P_estadisticas/HBoxContainer/Control2/Estadis/param/l_E
@onready var label_A =$P_estadisticas/HBoxContainer/Control2/Estadis/param/l_A
@onready var label_P =$P_estadisticas/HBoxContainer/Control2/Estadis/param/l_P

@onready var label_Atrav =$P_estadisticas/HBoxContainer/Control2/Estadis/resultados/l_atra
@onready var label_Rebo =$P_estadisticas/HBoxContainer/Control2/Estadis/resultados/l_rebo
@onready var label_Tiempo =$P_estadisticas/HBoxContainer/Control2/Estadis/resultados/l_tiempo
@onready var label_Inter =$P_estadisticas/HBoxContainer/Control2/Estadis/resultados/l_interf
@onready var control_msm = $P_estadisticas/HBoxContainer/Control
@onready var control_est = $P_estadisticas/HBoxContainer/Control2
@onready var confirm = $P_simulaciones/ConfirmationDialog
@onready var popup = $P_simulaciones/PopupPanel
@onready var lbl_pop = $P_simulaciones/PopupPanel/Label
@onready var graph = $P_estadisticas/HBoxContainer/Control2/Grafico/Graph2D
@onready var mensaje = $P_estadisticas/HBoxContainer/Control2/Panel/Mensaje

var graficos
func _ready():
	# Obtener el nombre Y el correo directamente de Global
	graficos = preload("res://Scripts/Estadisticas_T.gd").new()
	control_msm.visible = true
	control_est.visible = false
	var nombre:String = Global.nombre_U  
	if nombre != "":
		titulo_l.text = "¡ HOLA, " + nombre + " !" 
		nombre_l.text = " "+ nombre
	
	var correo:String = Global.correo_U
	if correo != "":
		correo_l.text = "" + correo
	
	cargar_simulacion()
	
#VOLVER AL HOME
func _on_button_home_pressed() -> void:
		get_tree().change_scene_to_file("res://Scenes/Home.tscn")


func _on_button_cerrar_sesion_pressed() -> void:
	Global.cerrar_sesion()
	get_tree().change_scene_to_file("res://Scenes/login.tscn")


func cargar_simulacion():
	for c in contenedor_simulaciones.get_children(): #limpia el contenedor 
		c.queue_free()

	var lista = Database.cargar_historial_db(Global.id_usuario)
	for sim in lista:
		var linea = crear_linea_simulacion(sim)
		contenedor_simulaciones.add_child(linea)

func aplicar_estilo_B(boton: Button, color: Color):
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.247, 0.247, 0.247, 0)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color.darkened(0.1)  #  poco más oscuro para efecto hover
	style_hover.corner_radius_bottom_left = 5
	style_hover.corner_radius_bottom_right =5
	style_hover.corner_radius_top_left= 5
	style_hover.corner_radius_top_right= 5
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = color.darkened(0.4)  #  más oscuro para efecto presionado

	boton.add_theme_stylebox_override("normal", style_normal)
	boton.add_theme_stylebox_override("hover", style_hover)
	boton.add_theme_stylebox_override("pressed", style_pressed)

		
func crear_linea_simulacion(sim: Dictionary) -> Button:
	var linea = Button.new()
	linea.focus_mode = Control.FOCUS_NONE
	linea.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linea.mouse_filter = Control.MOUSE_FILTER_STOP  # Acepta clics
	linea.custom_minimum_size.y = 25
	linea.custom_minimum_size.x = 610
	aplicar_estilo_B(linea,Color(0.319, 0.19, 0.378))
	
	# Contenedor para los datos
	var contenedor = HBoxContainer.new()
	contenedor.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# ID
	var lbl_id = Label.new()
	lbl_id.text = str(sim["id_simulacion"])
	lbl_id.custom_minimum_size.x = 40
	contenedor.add_child(lbl_id)

	# Título
	var lbl_nombre = Label.new()
	lbl_nombre.text = sim.get("titulo", "Sin título")
	lbl_nombre.custom_minimum_size.x = 140
	contenedor.add_child(lbl_nombre)

	# Fecha
	var lbl_fecha = Label.new()
	lbl_fecha.text = sim.get("tiempo", "")
	lbl_fecha.custom_minimum_size.x = 180
	contenedor.add_child(lbl_fecha)

	# Descripción
	var lbl_desc = Label.new()
	lbl_desc.text = sim.get("descripcion", "")
	lbl_desc.custom_minimum_size.x = 230
	lbl_desc.clip_text=true
	contenedor.add_child(lbl_desc)
	
	# Botón de eliminar
	var btn_eliminar = Button.new()
	btn_eliminar.icon = load("res://images/User/icons8-basura.png")
	btn_eliminar.tooltip_text = "Eliminar simulación"
	btn_eliminar.custom_minimum_size.x = 20
	btn_eliminar.focus_mode = Control.FOCUS_NONE
	aplicar_estilo_B(btn_eliminar,Color(0.506, 0.557, 0.824))
	contenedor.add_child(btn_eliminar)
	btn_eliminar.connect("pressed",Callable(self,"_on_eliminar_simulacion").bind(sim["id_simulacion"],linea))

	linea.add_child(contenedor)
	linea.connect("pressed", Callable(self, "_on_simulacion_seleccionada").bind(sim["id_simulacion"]))
	return linea
	
func _on_eliminar_simulacion(id_simulacion: int, linea: Control):
	_on_simulacion_seleccionada(id_simulacion)
	confirm.position = Vector2(950,300)
	confirm.popup()
	confirm.connect("confirmed",func():
		Database.eliminar_simulacion_id(id_simulacion,Global.id_usuario)
		linea.queue_free() #eliminar del historial lalinea
		control_msm.visible = true
		control_est.visible = false
		lbl_pop.text = " Simulación eliminada correctamente "
		popup.position = Vector2(950,300)
		popup.popup()
		,CONNECT_ONE_SHOT)

func _on_simulacion_seleccionada( id_simulacion: int):
		mensaje.visible = false
		control_msm.visible = false
		control_est.visible = true
		var sim = Database.obtener_simulacion_id(id_simulacion)
		mostrar_estadisticas(sim)

func mostrar_estadisticas(sim: SimulacionGuardada):	
	var p = sim.parametros
	var r = sim.resultados
	
	label_ID.text = "ID %s" % str(sim.id_simulacion)
	label_titulo.text = str(sim.titulo)
	label_Des.text = str(sim.descripcion)
	if sim.titulo == "Efecto Casimir":
		label_E.text = "D = %.2f eV" % p["distancia"]
		label_A.text = "A = %.2f mm" % p["ancho_placas"]
		label_P.text = "Modos = %d" % p["modos"]
		
		var distancia_final = float(r["distancia_final"])
		label_Atrav.text = "D. Inicial: %.2f eV" % p["distancia"]
		label_Rebo.text = "D. Final: %.3f nm" % ( distancia_final )
		var area = float(r["Area"])
		label_Tiempo.text = "Area: %.2f cm2" % (area)
		var force = float(r["fuerza_maxima"])
		label_Inter.text = "F. Casimir:\n %.2f" % (force)
		
	else : 
		label_E.text = "E = %.2f eV" % p["energia"]
		label_A.text = "A = %.2f mm" % p["ancho_barrera"]
		label_P.text = "Particulas = %d" % p["total_particulas"]

		label_Atrav.text = "Atravesaron: %d" % r["atravesaron"]
		label_Rebo.text = "Rebotaron: %d" % r["rebotaron"]
		label_Tiempo.text = "Tiempo: %.2f s" % r["tiempo"]
		label_Inter.text = str(r["interferencia"])

	graficos.mostrar_estadisticas_con_etiquetas(sim,graph)
	

func _on_b_historial_pressed() -> void:
	control_msm.visible = true
	control_est.visible = false
	confirm.dialog_text = "¿ Deseas eliminar el historial de simulaciones ?"
	confirm.position = Vector2(950,300)
	confirm.popup()
	
	confirm.connect("confirmed",func():
		Database.eliminar_simulaciones(Global.id_usuario)
		for linea in contenedor_simulaciones.get_children():
			linea.queue_free()
		
		lbl_pop.text = " Historial limpio correctamente"
		popup.position = Vector2(950,300)
		popup.popup()
		,CONNECT_ONE_SHOT)
	
