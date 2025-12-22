extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Rounds/rounds.value = Szorp.rounds
	$VBoxContainer/StarterPowerUps/starterPUps.value = Szorp.starterPowerUps
	$VBoxContainer/loserMutator.button_pressed = Szorp.roundEndMutators
	$VBoxContainer/Infected.button_pressed = Szorp.infectedMaps





func _on_check_box_toggled(toggled_on: bool) -> void:
	Szorp.infectedMaps = toggled_on
	print(Szorp.customInfected)

func _on_rounds_value_changed(value: float) -> void:
	Szorp.rounds = value

func _on_starter_p_ups_value_changed(value: float) -> void:
	Szorp.starterPowerUps = value

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/choose_character.tscn")


func _on_loser_mutator_toggled(toggled_on: bool) -> void:
	Szorp.roundEndMutators = toggled_on


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
