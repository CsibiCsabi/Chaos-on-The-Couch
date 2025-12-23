extends Control


@onready var card_container = $MarginContainer/VBoxContainer/HBoxContainer
@export var mutator_card_scene: PackedScene

func _ready() -> void:
	$MarginContainer/VBoxContainer/player.text = "Player " + str(Szorp.loser) + "'s choice!"
	show_random_mutators(3)

func show_random_mutators(count : int):
	var keys = Mutator_Library.all_mutators.keys()
	keys.shuffle()
	for i in range(min(keys.size(), count)):
		var key = "Stinger"
		var mutator = Mutator_Library.all_mutators[key]
		var card = mutator_card_scene.instantiate()
		card.setMutator(mutator)
		if mutator.rarity == Szorp.Rarity.common:
			print(mutator.name + ": common")
			card.theme = preload("res://themes/common_theme.tres")
		elif mutator.rarity == Szorp.Rarity.uncommon:
			card.theme = preload("res://themes/uncommon_theme.tres")
			print(mutator.name + ": uncommon")
		elif mutator.rarity == Szorp.Rarity.rare:
			card.theme = preload("res://themes/rare_theme.tres")
			print(mutator.name + ": rare")
		card.connect("mutator_selected", Callable(self, "_on_mutator_selected"))
		card_container.add_child(card)

func _on_mutator_selected(mutator : Mutator):
	print("kiválasztott mutator:" + mutator.name)
	
	if Szorp.loser == 1:
		Szorp.p1mutators.append(mutator)
	else:
		Szorp.p2mutators.append(mutator)
	Szorp.next_round()
