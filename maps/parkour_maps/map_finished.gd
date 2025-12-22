extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/time.text = "Your time: " + Szorp.finish_time



func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://maps/parkour_maps/level_loader.tscn")



func _on_next_pressed() -> void:
	Szorp.level += 1
	if Szorp.level > Szorp.parkour_levels:
		get_tree().change_scene_to_file("res://maps/parkour_maps/final_parkour.tscn")
	else:
		get_tree().change_scene_to_file("res://maps/parkour_maps/level_loader.tscn")
