extends MarginContainer

@onready var nombre_input = $CenterContainer/VBoxContainer/MarginContainer/LineEdit_nombre
@onready var correo_input = $CenterContainer/VBoxContainer/MarginContainer4/LineEdit_correo
@onready var contrasena_input =$CenterContainer/VBoxContainer/MarginContainer3/LineEdit_contrasena
@onready var label_info = $CenterContainer/VBoxContainer/MarginContainer5/Label_info

func validar_correo(correo: String) -> bool:
	var regex = RegEx.new()
	# expresion regular básica para validar correos 
	var pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
	var error = regex.compile(pattern)
	
	if error != OK:
		return false  # Si la expresión no compila retorna false por seguridad
	
	return regex.search(correo) != null  # Devuelve true si hay coincidencia

func _on_button_registrar_pressed() -> void:
	var nombre = nombre_input.text.strip_edges()
	var correo = correo_input.text.strip_edges()
	var contrasena = contrasena_input.text.strip_edges()
	
	if nombre.is_empty() or correo.is_empty() or contrasena.is_empty():
		label_info.text = "Rellene todos los campos."
		label_info.modulate = Color.RED
		return
	
	if not validar_correo(correo):
		label_info.text = "Correo inválido."
		label_info.modulate = Color.RED
		return
		
	var exito = Database.registro_usuario(nombre,correo,contrasena)
	
	if exito:
		Global.correo_U = correo
		label_info.text = "¡Registro exitoso!"
		await get_tree().create_timer(1.5).timeout 
		get_tree().change_scene_to_file("res://Scenes/login.tscn")
	else:
		label_info.text = "Correo ya registrado."
		
func limpiar_registro():
	nombre_input.text = ""
	correo_input.text = ""
	contrasena_input.text = ""
	label_info.text = ""
	label_info.modulate = Color.WHITE
