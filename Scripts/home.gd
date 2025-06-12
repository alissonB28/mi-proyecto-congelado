extends Control

#	Cambio de escenas cuando presionan un boton 
func _on_b_config_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_b_usuario_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/user.tscn")
	
func _on_b_salir_pressed() -> void:
	get_tree().quit()

#	cambio de escenas de las simulaciones
func _on_option_b_simula_item_selected(index: int):
	if index == 0:
		get_tree().change_scene_to_file("res://Scenes/simulacion_tunel.tscn")
	else :
		get_tree().change_scene_to_file("res://Scenes/simulacion_casimir.tscn")


func _on_button_acerca_de_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/acerca_de.tscn")


func _on_button_teoria_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/teoria.tscn")
