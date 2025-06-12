extends Node

var max_fps : int = 60
var resolution : Vector2i = Vector2i(1600, 900)
var calidad : int = 1
var reflejos_enabled : bool = false
var sombras_enabled : bool = false

var CONFIG_PATH := "user://settings.cfg"

func _ready():
	load_settings()
	apply_settings()


func apply_settings():
	Engine.max_fps = max_fps
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(resolution)
	centrar_ventana()

	match calidad:
		0:
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 0)
			ProjectSettings.set_setting("rendering/quality/shading/quality", 0)
		1:
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 2)
			ProjectSettings.set_setting("rendering/quality/shading/quality", 1)
		2:
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 4)
			ProjectSettings.set_setting("rendering/quality/shading/quality", 2)

	ProjectSettings.set_setting("rendering/environment/reflections/roughness_limiter_enabled", reflejos_enabled)
	ProjectSettings.set_setting("rendering/lights/directional_shadow/enable", sombras_enabled)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("graphics", "max_fps", max_fps)
	config.set_value("graphics", "resolution_x", resolution.x)
	config.set_value("graphics", "resolution_y", resolution.y)
	config.set_value("graphics", "calidad", calidad)
	config.set_value("graphics", "reflejos_enabled", reflejos_enabled)
	config.set_value("graphics", "sombras_enabled", sombras_enabled)

	var error = config.save(CONFIG_PATH)
	if error != OK:
		print("Error al guardar configuración: ", error)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		max_fps = config.get_value("graphics", "max_fps", 60)
		var res_x = config.get_value("graphics", "resolution_x", 1280)
		var res_y = config.get_value("graphics", "resolution_y", 720)
		resolution = Vector2i(res_x, res_y)
		calidad = config.get_value("graphics", "calidad", 1)
		reflejos_enabled = config.get_value("graphics", "reflejos_enabled", false)
		sombras_enabled = config.get_value("graphics", "sombras_enabled", false)
	else:
		# por defecto si no existe archivo
		max_fps = 60
		resolution = Vector2i(1600, 900)
		calidad = 1
		reflejos_enabled = false
		sombras_enabled = false
#centrado 
func centrar_ventana():
	var screen_size = DisplayServer.screen_get_size()
	var window_pos = (screen_size - resolution) / 2
	DisplayServer.window_set_position(window_pos)
