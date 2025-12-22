extends Control

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_choose_level_pressed() -> void:
	get_tree().change_scene_to_file("res://maps/parkour_maps/choose_level.tscn")
