extends Control

@export var icon: Texture2D
@export var label: String = ""  # Se especifica que es String
@export var active: bool = false
@export var page: NodePath
@export var scroll_container: NodePath

func _ready():
	# Verifica que los nodos existen y que sean del tipo correcto antes de asignar
	$icon.texture = icon  # Asigna la textura correctamente
	$label.text = label  # Asigna el texto correctamente
	update_elements()
	
func set_active():
	active = true
	update_elements()
	
	# Reinicia el ScrollContainer si está asignado
	if has_node(scroll_container):
		var scroll = get_node(scroll_container)
		if scroll is ScrollContainer:
			scroll.set_v_scroll(0)  # Reinicia el scroll vertical
	
func desactive():
	active = false
	update_elements()

func update_elements():
	if has_node("active"):  # Verifica que el nodo existe antes de modificarlo
		$active.visible = active
		get_node(page).visible = active
	
func _on_mouse_entered() -> void:
	if has_node("bg") and $bg is ColorRect:
		$bg.color = Color("#180e46")  # Convierte el string a Color
		
	
func _on_mouse_exited() -> void:
	if has_node("bg") and $bg is ColorRect:
		$bg.color = Color("08080830")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var rendijas = get_tree().get_nodes_in_group("rendija")
			for item in rendijas:
				item.desactive()
			set_active()

#boton de la teoria que hace el redirect
func _on_b_simulacion_t_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/simulacion_tunel.tscn")
