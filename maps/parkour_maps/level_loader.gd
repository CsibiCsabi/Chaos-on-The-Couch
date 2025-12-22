extends Node2D

var current_level = 1
var p1pos
var max_jumps
var max_nairs
var gravity
var timer = 0.0
@onready var timer_text = $p1/CanvasLayer/Timer
@onready var map_container = $MapContainer

func _ready() -> void:
	current_level = Szorp.level
	load_map()
	$p1.maxJumps = max_jumps
	$p1.maxNairs = max_nairs
	$p1.gravityMultiplier = gravity
	$CanvasLayer/StartScreen.show_start(max_jumps, current_level, max_nairs, gravity)

func load_map():
	print(current_level)
	var scene = load("res://maps/parkour_maps/level"+str(current_level)+".tscn").instantiate()
	map_container.add_child(scene)
	#player elhelyezing
	p1pos = scene.get_node("player1position").global_position 
	$p1.global_position = p1pos
	#finish_area stuff
	var finish_node = scene.get_node("finish_area")
	max_jumps = scene.max_jumps
	max_nairs = scene.max_nairs
	gravity = scene.gravity
	finish_node.level_completed.connect(finish)

func restart():
	timer = 0
	$p1.global_position = p1pos
	$p1.velocity = Vector2(0,0)
	$p1.collision_mask |= (1 << 3)


func _process(delta: float) -> void:
	timer += delta
	timer_text.text = "your time: " + String.num(timer, 2)

func finish():
	print("Time: " + String.num(timer, 2))
	Szorp.finish_time = String.num(timer, 2)
	get_tree().change_scene_to_file("res://maps/parkour_maps/map_finished.tscn")
	return
