extends Node3D

@onready var mesh_instance := $"."

var tiempo := 0.0

# Valores desde la simulación
var masa := 1.0
var energia := 1.0
var ancho_barrera := 1.0
var atraveso := false
var reboto := false
const HBAR = 1.0

func _ready():
	mesh_instance.mesh = ImmediateMesh.new()

func _process(delta):
	tiempo += delta
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_STRIP)

	var E = energia
	var m = masa
	var k = sqrt(2.0 * m * E) / HBAR
	var omega = HBAR * k * k / (2.0 * m)

	for x in range(-100, 100):
		var x_f = x / 10.0
		var psi := 0.0

		# Onda incidente desde la izquierda
		if x_f < 0.0:
			psi = sin(k * x_f - omega * tiempo)

			# Si rebota, hay interferencia (reflejada)
			if reboto:
				psi += sin(-k * x_f - omega * tiempo)
		
		# Dentro de la barrera
		elif x_f >= 0.0 and x_f <= ancho_barrera:
			var V0 := 5.0
			if E < V0:
				var gamma = sqrt(2.0 * m * (V0 - E)) / HBAR
				psi = exp(-gamma * x_f) * sin(omega * tiempo)
			else:
				psi = sin(k * x_f - omega * tiempo)

		# Después de la barrera (transmitida)
		else:
			if atraveso:
				psi = sin(k * x_f - omega * tiempo)
			else:
				psi = 0.0  # No pasó

		var prob = psi * psi
		st.add_vertex(Vector3(x_f, prob * 2.0, 0))  # Escala visual

	mesh_instance.mesh.clear_surfaces()
	st.commit(mesh_instance.mesh)
