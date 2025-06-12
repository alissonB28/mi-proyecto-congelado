extends Panel
@onready var anim_player =$AnimationPlayer
@onready var registro_form = $"../MC_Registro" 
@onready var login_form = $"../Animacion_login/MC_Login"
func _on_b_registrar_pressed() -> void:
	registro_form.limpiar_registro()
	anim_player.play_backwards("Login")


func _on_b_inicio_pressed() -> void:
	login_form.limpiar_login()
	anim_player.play("Login")
