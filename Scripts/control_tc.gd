extends Control

@onready var sl_energia = $P_control/L_energia/HSlider
@onready var sl_ancho = $P_control/L_ancho/HSlider
@onready var sl_particulas= $P_control/L_particulas/HSlider
@onready var tag_particulas = $P_control/L_particulas/tag_m


@onready var tag_e_l = $P_control/L_energia/tag_e
@onready var tal_an_l =$P_control/L_ancho/tag_a

@onready var b_guardar = $P_control/B_guardar
@onready var b_resultados = $P_control/B_resultados


func _ready():
	sl_particulas.value_changed.connect(slider_particulas)
	slider_particulas(sl_particulas.value)
	sl_energia.value_changed.connect(slider_energia)
	slider_energia(sl_ancho.value)
	sl_ancho.value_changed.connect(slider_ancho)
	slider_ancho(sl_energia.value)

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
		get_tree().change_scene_to_file("res://Scenes/simulacion_casimir.tscn")
		

func slider_particulas(value):
	tag_particulas.text = str(int(value)) +" particulas"

func slider_energia(value):
	tag_e_l.text =  str(int(value)) + " eV"
	
func slider_ancho(value):
	tal_an_l.text =  str(int(value)) + " nm"
	
	
	
