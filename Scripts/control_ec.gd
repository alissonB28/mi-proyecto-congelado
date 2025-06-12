extends Control

@onready var sl_distancia = $P_control/L_distancia/HSlider
@onready var sl_ancho = $P_control/L_ancho/HSlider
@onready var sl_modos= $P_control/L_modos/HSlider

@onready var tag_modos = $P_control/L_modos/tag_m
@onready var tag_dis = $P_control/L_distancia/tag_d
@onready var tal_an =$P_control/L_ancho/tag_a

@onready var b_guardar = $P_control/B_guardar
@onready var b_resultados = $P_control/B_resultados


func _ready():
	sl_modos.value_changed.connect(slider_modos)
	slider_modos(sl_modos.value)
	
	sl_distancia.value_changed.connect(slider_distancia)
	slider_distancia(sl_distancia.value)
	
	sl_ancho.value_changed.connect(slider_ancho)
	slider_ancho(sl_ancho.value)

#control de paginas--------------------------------------------
func _on_config_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
	
func _on_user_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/user.tscn")
	
func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/teoria.tscn")
	
func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		get_tree().change_scene_to_file("res://Scenes/simulacion_tunel.tscn")
		

func slider_modos(value):
	tag_modos.text = str(int(value)) +" (n)"

func slider_distancia(value):
	tag_dis.text =  str(int(value)) + " nm"
	
func slider_ancho(value):
	tal_an.text =  str(int(value)) + " mm"
	
	
	
