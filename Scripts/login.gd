extends MarginContainer

@onready var correo_input = $CenterContainer/VBoxContainer/MarginContainer/LineEdit_correo
@onready var contrasena_input = $CenterContainer/VBoxContainer/MarginContainer3/LineEdit_contrasena
@onready var error_label = $CenterContainer/VBoxContainer/MarginContainer4/Label_error

# Método para hashear la contraseña
func hash_contrasena(contrasena: String) -> String:
	var hasher = HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(contrasena.to_utf8_buffer())
	return hasher.finish().hex_encode()

# Login
func _on_button_login_pressed():
	var correo = correo_input.text.strip_edges()
	var contrasena = contrasena_input.text.strip_edges()
	
	# Comprobar si los campos están vacíos
	if correo.is_empty() or contrasena.is_empty():
		error_label.text = "Rellene todos los campos."
		return
	
	# Generar el hash de la contraseña ingresada
	var contrasena_hash = hash_contrasena(contrasena)
	
	# Consultar el usuario por correo y comparar el hash de la contraseña
	var query_login = "SELECT * FROM usuario WHERE correo = '%s' AND contrasena = '%s'" % [correo.replace("'", "''"), contrasena_hash]
	var success = Database.db.query(query_login)
	
	# Verificar si el usuario existe
	if success and Database.db.query_result.size() == 1:
		# Guardar el ID del usuario para futuras simulaciones
		Global.id_usuario = Database.db.query_result[0]["id_usuario"]
		Global.correo_U = Database.db.query_result[0]["correo"]
		Global.nombre_U = Database.db.query_result[0]["nombre"]
		Global.guardar_sesion()
		# Cambiar de escena o mostrar ventana de usuario
		get_tree().change_scene_to_file("res://Scenes/Home.tscn")
	else:
		# Si el login falla, mostrar el mensaje de error
		error_label.text = "Correo o contraseña incorrectos."
		
		
func limpiar_login():
	correo_input.text = ""
	contrasena_input.text = ""
	error_label.text = ""
	error_label.modulate = Color.WHITE
