extends Control

var puntos_data = []  # Guardaremos los puntos para dibujar etiquetas
var datos = {}
var colores = {}

func mostrar_estadisticas_con_etiquetas(sim: SimulacionGuardada, graph_node: Graph2D):
	graph_node.remove_all()
	puntos_data.clear()
	limpiar_etiquetas_texto(graph_node)

	# Definir datos y colores según el tipo de simulación
	if sim.titulo == "Efecto Casimir":
		datos = {
			"D. inicial": sim.resultados["distancia_inicial"],
			"D. final": sim.resultados["distancia_final"],
			"Fuerza": sim.resultados["fuerza_maxima"]
		}
		colores = {
			"D. inicial": Color.SKY_BLUE,
			"D. final": Color.DARK_BLUE,
			"Fuerza": Color.AQUA
		}
	else:
		datos = {
			"Atravesaron": sim.resultados["atravesaron"],
			"Rebotaron": sim.resultados["rebotaron"],
			"Tiempo": sim.resultados["tiempo"]
		}
		colores = {
			"Atravesaron": Color.DARK_GOLDENROD,
			"Rebotaron": Color.DARK_RED,
			"Tiempo": Color.DARK_BLUE
		}

	# Establecer límites del gráfico automáticamente
	graph_node.x_min = -0.5
	graph_node.x_max = float(datos.size()) - 0.5
	graph_node.y_min = 0

	var max_val = 0.0
	for v in datos.values():
		if typeof(v) in [TYPE_FLOAT, TYPE_INT] and v > max_val:
			max_val = v
	graph_node.y_max = max_val * 1.2 if max_val > 0 else 1.0

	var puntos_para_conexion = []
	var x = 0

	for nombre in datos.keys():
		var valor = float(datos[nombre])
		var centro = Vector2(x, valor)

		var plot = graph_node.add_plot_item(" ", colores[nombre], 3.0)
		plot.add_point(Vector2(x, 0))  # Base de la barra
		plot.add_point(Vector2(x, valor))  # Altura

		# Círculo en el extremo superior
		var radio = 0.03
		var num_puntos = 8
		for i in range(num_puntos + 1):
			var angulo = (i * 2 * PI) / num_puntos
			var punto_circulo = Vector2(
				centro.x + radio * cos(angulo),
				centro.y + radio * sin(angulo)
			)
			plot.add_point(punto_circulo)

		puntos_para_conexion.append(centro)
		puntos_data.append({
			"pos": centro,
			"texto": "%s: %.2f" % [nombre, valor],
			"valor_solo": "%.2f" % valor
		})

		crear_etiqueta_x(nombre, x, graph_node)
		x += 1

	# Conectar puntos con línea si hay mas de uno
	if puntos_para_conexion.size() > 1:
		puntos_para_conexion.sort_custom(func(a, b): return a.x < b.x)
		var plot_conexion = graph_node.add_plot_item(" ", Color.NAVAJO_WHITE, 1.0)
		for punto in puntos_para_conexion:
			plot_conexion.add_point(punto)

	# Crear etiquetas flotantes sobre los puntos
	crear_etiquetas_sobre_puntos(graph_node)


func crear_etiquetas_sobre_puntos(graph: Graph2D):
	var plot_area = graph.get_node("PlotArea")

	for punto_data in puntos_data:
		var pos_grafico = punto_data.pos
		var pos_px = Vector2()
		pos_px.x = remap(pos_grafico.x, graph.x_min, graph.x_max, 0, plot_area.size.x)
		pos_px.y = remap(pos_grafico.y, graph.y_min, graph.y_max, plot_area.size.y, 0)

		var label = Label.new()
		label.text = punto_data.valor_solo
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 12)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var offset_x = label.get_minimum_size().x / 2
		label.position = pos_px - Vector2(offset_x, 20)

		plot_area.add_child(label)

		if not graph.has_meta("etiquetas_texto"):
			graph.set_meta("etiquetas_texto", [])
		graph.get_meta("etiquetas_texto").append(label)


func crear_etiqueta_x(texto: String, x_val: float, graph: Graph2D):
	var plot_area = graph.get_node("PlotArea")
	var label = Label.new()
	label.text = texto
	label.add_theme_color_override("font_color", Color.CORNSILK)
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var pos_px_x = remap(x_val, graph.x_min, graph.x_max, 0, plot_area.size.x)
	label.position = Vector2(pos_px_x - 30, plot_area.size.y + 20)

	plot_area.add_child(label)

	if not graph.has_meta("etiquetas_x"):
		graph.set_meta("etiquetas_x", [])
	graph.get_meta("etiquetas_x").append(label)


func limpiar_etiquetas_texto(graph: Graph2D):
	if graph.has_meta("etiquetas_texto"):
		for etiqueta in graph.get_meta("etiquetas_texto"):
			if is_instance_valid(etiqueta):
				etiqueta.queue_free()
		graph.set_meta("etiquetas_texto", [])

	if graph.has_meta("etiquetas_x"):
		for etiqueta in graph.get_meta("etiquetas_x"):
			if is_instance_valid(etiqueta):
				etiqueta.queue_free()
		graph.set_meta("etiquetas_x", [])
