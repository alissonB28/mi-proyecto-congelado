extends RigidBody3D

var callback_node: Node = null
var resultado_enviado: bool = false
var energia: float
var masa: float = 1.0 
var ancho_barrera: float
var posicion_barrera: float

var V0 := 5.0

func _ready():
	randomize()

func _physics_process(_delta):
	if resultado_enviado:
		return

	# Si cruza el umbral cercano a la barrera
	if abs(global_position.x - posicion_barrera) < 0.1:
		var paso = calcular_probabilidad()

		if not paso:
			linear_velocity.x *= -1  # Rebote visual

		if callback_node:
			callback_node.notificar_resultado(paso)

		resultado_enviado = true
		await get_tree().create_timer(0.9).timeout
		queue_free()

	# Si se sale del área visible sin colisión
	if global_position.x < -10 or global_position.x > 10:
		if not resultado_enviado and callback_node:
			callback_node.notificar_resultado(false)
		resultado_enviado = true
		queue_free()

func calcular_probabilidad() -> bool:
	var E = energia
	var m = masa
	var L = ancho_barrera
	var T = 0.0

	if E >= V0:
		T = 1.0
	else:
		var diferencia = V0 - E
		var gamma = sqrt(2.0 * m * diferencia)
		T = exp(-2.0 * gamma * L)

	T = clamp(T, 0.0, 1.0)
	return randf() < T
