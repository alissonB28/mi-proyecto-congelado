class_name  SimulacionGuardada
extends RefCounted

var id_simulacion: int
var id_usuario: int 
var titulo: String
var tiempo: String
var parametros: Dictionary 
var resultados: Dictionary
var descripcion: String

#Constructor
func _init(
	_id_simulacion :=0,
	_id_usuario := 0,
	_titulo := "",
	_tiempo := "",
	_parametros := {},
	_resultados := {},
	_descripcion := ""
):
	id_simulacion =_id_simulacion
	id_usuario = _id_usuario
	titulo = _titulo
	tiempo = _tiempo
	parametros = _parametros
	resultados = _resultados
	descripcion = _descripcion

#Parecido al tostring
func to_dict() -> Dictionary:
	return {
		"id_simulacion" : id_simulacion,
		"id_usuario" : id_usuario,
		"titulo" : titulo,
		"tiempo" : tiempo,
		"parametros" : JSON.stringify(parametros),
		"resultados" : JSON.stringify(resultados),
		"descripcion" : descripcion
	}
