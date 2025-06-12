extends Panel
@onready var correo_input = $MC_Contrasena/CenterContainer/VBoxContainer/MarginContainer/LineEdit_correo
@onready var nueva_contrasena_input = $MC_Contrasena/CenterContainer/VBoxContainer/MarginContainer3/LineEdit_contrasena
@onready var repetir_contrasena_input =$MC_Contrasena/CenterContainer/VBoxContainer/MarginContainer5/LineEdit_repetir
@onready var label_info = $MC_Contrasena/CenterContainer/VBoxContainer/MarginContainer4/Label_error
@onready var anim = $AnimationPlayer

@onready var login_form = $MC_Login

func _on_button_reestablecer_pressed() -> void:
	login_form.limpiar_login()
	anim.play("AnimRestaurar_pws")

func hash_contrasena(contrasena: String) -> String:
	var hasher = HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(contrasena.to_utf8_buffer())
	return hasher.finish().hex_encode()
	
func _on_button_aceptar_pressed() -> void:
	
	var correo = correo_input.text.strip_edges()
	var nueva_contrasena = nueva_contrasena_input.text.strip_edges()
	var repetir_contrasena = repetir_contrasena_input.text.strip_edges()
	
	if correo.is_empty() or nueva_contrasena.is_empty() or repetir_contrasena.is_empty():
		label_info.text = "Complete todos los campos."
		label_info.modulate = Color.RED
		return
	
	if nueva_contrasena != repetir_contrasena:
		label_info.text = "Las contraseñas no coinciden."
		label_info.modulate = Color.RED
		return
	
	var query = "SELECT * FROM usuario WHERE correo = '%s'" % correo.replace("'", "''")
	if not Database.db.query(query) or Database.db.query_result.size() == 0:
		label_info.text = "Correo no registrado."
		label_info.modulate = Color.RED
		return

	var hash_nueva = hash_contrasena(nueva_contrasena)
	var update = "UPDATE usuario SET contrasena = '%s' WHERE correo = '%s'" % [
		hash_nueva.replace("'", "''"),
		correo.replace("'", "''")
	]
	Database.db.query(update)
	
	label_info.add_theme_color_override("font_color", Color.WHITE)
	label_info.text = "¡Contraseña actualizada!"
	await get_tree().create_timer(1.0).timeout 
	limpiar_recuperacion()
	anim.play_backwards("AnimRestaurar_pws")

func limpiar_recuperacion():
	correo_input.text = ""
	nueva_contrasena_input.text = ""
	repetir_contrasena_input.text = ""
	label_info.text = ""
	label_info.modulate = Color.WHITE

func _on_button_cancelar_pressed() -> void:
	limpiar_recuperacion()
	anim.play_backwards("AnimRestaurar_pws")
