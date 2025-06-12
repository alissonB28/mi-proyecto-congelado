extends Node

# Singleton para guardar variables y preferencias del usuario
var id_usuario: int = -1
var nombre_U: String = ""
var correo_U: String = ""
var calidad = 2  # 0 = baja, 1 = media, 2 = alta

const CONFIG_PATH = "user://sesion.json"

func guardar_sesion():
	var datos = {
		"id_usuario": id_usuario,
		"nombre_U": nombre_U,
		"correo_U": correo_U
	}
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(datos))

func cargar_sesion() -> bool:
	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		var contenido = file.get_as_text()
		var datos = JSON.parse_string(contenido)
		if typeof(datos) == TYPE_DICTIONARY:
			id_usuario = datos.get("id_usuario", -1)
			nombre_U = datos.get("nombre_U", "")
			correo_U = datos.get("correo_U", "")
			return true
	return false

func cerrar_sesion():
	if FileAccess.file_exists(CONFIG_PATH):
		DirAccess.remove_absolute(CONFIG_PATH)
