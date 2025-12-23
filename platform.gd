extends Node2D

@onready var p1 = $p1
@onready var p2 = $p2
@export var mutator_box_scene : PackedScene



func _ready() -> void:
	select_random_map()
	if Szorp.chosen_gamemode == Szorp.Gamemode.infected or Szorp.infectedMaps:
		print("infectedunk van")
		applyMapMutator()

var current_frame : int = 0

func advance_frame():
	current_frame += 1

var frame_counter : int = 0
var last_time : float = 0.0

func _physics_process(delta: float) -> void:
	frame_counter += 1
	
	# Print FPS every second
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_time >= 1.0:
		print("ACTUAL FPS: ", frame_counter, " (should be 60)")
		frame_counter = 0
		last_time = current_time
	
	advance_frame()
	for player in get_tree().get_nodes_in_group("players"):
		player.update_frame(current_frame)


func applyMapMutator():
	var muts = ceil(Szorp.round / float(2))
	for i in range(muts):
		Szorp.newMapMutator()
		var mut = Szorp.mapMutator
		p1.apply_map_mutator(mut)
		p2.apply_map_mutator(mut)
		var box = mutator_box_scene.instantiate()
		box.setMutator(mut)
		if mut.rarity == Szorp.Rarity.common:
			box.theme = preload("res://themes/common_theme.tres")
		elif mut.rarity == Szorp.Rarity.uncommon:
			box.theme = preload("res://themes/uncommon_theme.tres")
		elif mut.rarity == Szorp.Rarity.rare:
			box.theme = preload("res://themes/rare_theme.tres")
		$CanvasLayer/Mutators.add_child(box)
	

func select_random_map():
	var map = Szorp.map_paths.pick_random()
	var scene = load(map).instantiate()
	$MapContainer.add_child(scene)
	var p1pos = scene.get_node("player1position").global_position 
	var p2pos = scene.get_node("player2position").global_position 
	p1.global_position = p1pos
	p2.global_position = p2pos
