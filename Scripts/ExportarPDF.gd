extends Panel

@onready var graph_node = $HBoxContainer/Control2/Grafico/Graph2D  
@onready var mensaje = $HBoxContainer/Control2/Panel/Mensaje
@onready var l_titulo = $HBoxContainer/Control2/Estadis/l_titulo
@onready var l_E = $HBoxContainer/Control2/Estadis/param/l_E
@onready var l_A = $HBoxContainer/Control2/Estadis/param/l_A
@onready var l_P = $HBoxContainer/Control2/Estadis/param/l_P
@onready var l_des = $HBoxContainer/Control2/Estadis/desc/l_des
@onready var l_atra = $HBoxContainer/Control2/Estadis/resultados/l_atra
@onready var l_rebo = $HBoxContainer/Control2/Estadis/resultados/l_rebo
@onready var l_tiempo = $HBoxContainer/Control2/Estadis/resultados/l_tiempo
@onready var l_interf = $HBoxContainer/Control2/Estadis/resultados/l_interf
@onready var tit = "ESTADISTICAS DE LA SIMULACION : "

func _on_b_pdf_pressed() -> void:
	mensaje.visible = true
	PDF.newPDF()
	PDF.setTitle("Simulación: " + l_tiempo.text)
	PDF.setCreator("Evanesce")
	
		# 📌 1. Logo
	var logo = load("res://logoEvanesce.png")
	if logo and logo is Texture2D:
		var logo_img = logo.get_image()
		if logo_img:
			PDF.newImage(1, Vector2(300, 30), logo_img, Vector2(300, 50))  # Posición y tamaño del logo

	# 📌 2. Encabezado
	PDF.newFont("JosefinSans", "res://Fonts/static/JosefinSans-Bold.ttf")


	if l_titulo.text == "Efecto Casimir":
		var sim = "EFECTO CASIMIR"
		PDF.newLabel(1, Vector2(50, 140),  tit , 22 ,"JosefinSans" )
		PDF.newLabel(1, Vector2(50, 160),  sim , 18 ,"JosefinSans" )
		
		PDF.newLabel(1, Vector2(50, 210), "Fecha: " + Time.get_datetime_string_from_system().replace("T" , " "),14)
		PDF.newLabel(1, Vector2(50, 230), "Usuario: " + Global.nombre_U,14)		

		PDF.newLabel(1, Vector2(350, 270), "Parametros :  " , 16 ,"JosefinSans")
		PDF.newLabel(1, Vector2(350, 300), l_E.text, 12  )
		PDF.newLabel(1, Vector2(350, 320), l_A.text, 12  )
		PDF.newLabel(1, Vector2(350, 340),  l_P.text, 12 )
		
		PDF.newLabel(1, Vector2(100, 270), "Resultados :  " , 16,"JosefinSans" )
		PDF.newLabel(1, Vector2(100, 300),  l_atra.text, 12  )
		PDF.newLabel(1, Vector2(100, 320),  l_rebo.text, 12  )
		PDF.newLabel(1, Vector2(100, 340), l_tiempo.text, 12 )
		PDF.newLabel(1, Vector2(100, 360),  l_interf.text, 12  )
		PDF.newLabel(1, Vector2(100, 380),  "Comentarios : "+ l_des.text, 12  )
	else :
		var sim = "TUNEL CUANTICO"
		PDF.newLabel(1, Vector2(50, 140),  tit , 22 ,"JosefinSans" )
		PDF.newLabel(1, Vector2(50, 160),  sim , 18 ,"JosefinSans" )
		
		PDF.newLabel(1, Vector2(50, 210), "Fecha: " + Time.get_datetime_string_from_system().replace("T" , " "),14)
		PDF.newLabel(1, Vector2(50, 230), "Usuario: " + Global.nombre_U,14)

		PDF.newLabel(1, Vector2(350, 270), "Parametros :  " , 16 ,"JosefinSans")
		PDF.newLabel(1, Vector2(350, 300), l_E.text, 12  )
		PDF.newLabel(1, Vector2(350, 320), l_A.text, 12  )
		PDF.newLabel(1, Vector2(350, 340),  l_P.text, 12 )
		
		PDF.newLabel(1, Vector2(100, 270), "Resultados :  " , 16,"JosefinSans" )
		PDF.newLabel(1, Vector2(100, 300),  l_atra.text, 12  )
		PDF.newLabel(1, Vector2(100, 320),  l_rebo.text, 12  )
		PDF.newLabel(1, Vector2(100, 340), l_tiempo.text, 12 )
		PDF.newLabel(1, Vector2(100, 360), l_interf.text, 12  )
		PDF.newLabel(1, Vector2(100, 380),  "Comentarios : "+ l_des.text, 12  )

	

	# Capturar solo la gráfica
	var imagen_grafica = await capturar_desde_viewport_directo(graph_node)
	if imagen_grafica:
		PDF.newImage(1, Vector2(100, 450), imagen_grafica, Vector2(400, 200))
	else:
		print("⚠️ No se pudo capturar la imagen de la gráfica.")

	# Exportar
	if l_titulo.text == "Efecto Casimir":
		var base_path = getDesktopPath() + "/SimulacionCasimir.pdf"
		var path = generar_nombre_unico(base_path)
		var status = PDF.export(path)
		if status:
			mensaje.text = "✅ PDF exportado correctamente"
			
		else:
			mensaje.text = "❌ Error al exportar el PDF."

	else: 
		var base_path = getDesktopPath() + "/SimulacionTunelCuantico.pdf"
		var path = generar_nombre_unico(base_path)
		var status = PDF.export(path)
		if status:
			mensaje.text = "✅ PDF exportado correctamente"
		else:
			mensaje.text = "❌ Error al exportar el PDF."

func generar_nombre_unico(base_path: String) -> String:
	var path = base_path
	var contador = 1
	while FileAccess.file_exists(path):
		var extension_index = base_path.rfind(".") #vbusca el punto final
		if extension_index != -1:
			var nombre_base = base_path.substr(0, extension_index)
			var extension = base_path.substr(extension_index)
			path = "%s_(%d)%s" % [nombre_base, contador, extension]
		else:
			path = "%s_(%d)" % [base_path, contador]
		contador += 1
	return path


# 🔍 Captura solo el área visible del nodo gráfico con ajustes de posición
func capturar_desde_viewport_directo(grafica: Control) -> Image:
	# Guardar referencias para restaurar después
	var original_parent = grafica.get_parent()
	var original_index = original_parent.get_children().find(grafica)

	# Remover la gráfica de su padre temporalmente
	original_parent.remove_child(grafica)

	# Crear un SubViewport del mismo tamaño que la gráfica
	var viewport := SubViewport.new()
	viewport.size = grafica.size
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.own_world_3d = false
	add_child(viewport)  # Añadir temporalmente a la escena

	# Crear un contenedor y añadir la gráfica
	var container := Control.new()
	container.size = grafica.size
	viewport.add_child(container)
	container.add_child(grafica)

	await RenderingServer.frame_post_draw  # Esperar renderizado

	# Obtener imagen del viewport
	var image := viewport.get_texture().get_image()

	# Restaurar la gráfica a su posición original
	container.remove_child(grafica)
	original_parent.add_child(grafica)
	original_parent.move_child(grafica, original_index)

	# Limpiar viewport temporal
	remove_child(viewport)
	viewport.queue_free()

	return image



# Obtener ruta al escritorio
func getDesktopPath() -> String:
	return OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
