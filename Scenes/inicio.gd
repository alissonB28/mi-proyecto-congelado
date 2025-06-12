extends Node

func _ready():
	if Global.cargar_sesion():
		call_deferred("cargar_escena", "res://Scenes/Home.tscn")
	else:
		call_deferred("cargar_escena", "res://Scenes/login.tscn")

func cargar_escena(ruta: String) -> void:
	get_tree().change_scene_to_file(ruta)
