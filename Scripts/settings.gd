extends Control

@onready var fps_slider = $TabContainer/Ajustes/HSlider
@onready var fps_label = $TabContainer/Ajustes/Fps
@onready var res_button = $TabContainer/Ajustes/OptionButton_res
@onready var calidad_button = $TabContainer/Ajustes/OptionButton_cal
@onready var reflejos_check = $TabContainer/Ajustes/check_reflejos
@onready var sombras_check = $TabContainer/Ajustes/check_sombras
@onready var boton_reestablecer = $TabContainer/Ajustes/reestablecer

const DICCIONARIO_RESOLUCION : Dictionary = {
	"1152 x 648" : Vector2i(1152, 648),
	"1280 x 720" : Vector2i(1280, 720),
	"1366 x 768" : Vector2i(1366, 768),
	"1600 x 900" : Vector2i(1600, 900),
	"1920 x 1080" : Vector2i(1920, 1080),
	"2560 x 1440" : Vector2i(2560, 1440),
	"3840 x 2160" : Vector2i(3840, 2160)
}

func _ready():
	# Asegurar que siempre esté en modo ventana
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# Conexiones
	fps_slider.value_changed.connect(fps_slider_cambiado)
	res_button.item_selected.connect(on_resolucion_selected)
	calidad_button.item_selected.connect(on_calidad_selected)
	reflejos_check.toggled.connect(on_reflejos_toggled)
	sombras_check.toggled.connect(on_sombras_toggled)
	boton_reestablecer.pressed.connect(_on_reestablecer_pressed)

	add_resolucion_items()
	add_calidad_items()

	sincronizar_con_config()

# FPS Slider
func fps_slider_cambiado(value):
	ConfigManager.max_fps = int(value)
	fps_label.text = str(int(value)) + " FPS"
	ConfigManager.apply_settings()
	ConfigManager.save_settings()

# Añadir resoluciones al OptionButton
func add_resolucion_items() -> void:
	for res_text_size in DICCIONARIO_RESOLUCION.keys():
		res_button.add_item(res_text_size)

func on_resolucion_selected(index: int) -> void:
	var keys = DICCIONARIO_RESOLUCION.keys()
	var selected_res = DICCIONARIO_RESOLUCION[keys[index]]
	ConfigManager.resolution = selected_res
	ConfigManager.apply_settings()
	ConfigManager.save_settings()

# Añadir calidad gráfica
func add_calidad_items():
	calidad_button.add_item("Baja")
	calidad_button.add_item("Media")
	calidad_button.add_item("Alta")

func on_calidad_selected(index: int):
	ConfigManager.calidad = index
	ConfigManager.apply_settings()
	ConfigManager.save_settings()

# Checkboxes
func on_reflejos_toggled(enabled: bool):
	ConfigManager.reflejos_enabled = enabled
	ConfigManager.apply_settings()
	ConfigManager.save_settings()

func on_sombras_toggled(enabled: bool):
	ConfigManager.sombras_enabled = enabled
	ConfigManager.apply_settings()
	ConfigManager.save_settings()

# Reestablecer valores por defecto
func _on_reestablecer_pressed():
	res_button.select(0)
	on_resolucion_selected(0)

	fps_slider.value = 60
	fps_slider_cambiado(60)

	calidad_button.select(1)
	on_calidad_selected(1)

	reflejos_check.button_pressed = false
	sombras_check.button_pressed = false
	on_reflejos_toggled(false)
	on_sombras_toggled(false)

func sincronizar_con_config():
	fps_slider.value = ConfigManager.max_fps
	fps_label.text = str(ConfigManager.max_fps) + " FPS"

	var res_index = DICCIONARIO_RESOLUCION.values().find(ConfigManager.resolution)
	if res_index != -1:
		res_button.select(res_index)

	calidad_button.select(ConfigManager.calidad)
	reflejos_check.button_pressed = ConfigManager.reflejos_enabled
	sombras_check.button_pressed = ConfigManager.sombras_enabled

func _on_b_home_config_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")
