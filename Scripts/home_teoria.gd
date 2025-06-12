extends Control

@onready var anim_player = $"../../../../../AnimationPlayer"

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and event.is_pressed():
			if $"../../..".custom_minimum_size.x==70:
				anim_player.play("side_bar_anim")
			else:
				anim_player.play_backwards("side_bar_anim")


func _on_button_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")


func _on_button_sim_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/simulacion_casimir.tscn")
