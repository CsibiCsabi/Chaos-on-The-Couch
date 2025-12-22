extends Node

var p1color : Color
var p2color : Color
var winnerText : String
var p1mutators : Array[Mutator] = []
var p2mutators : Array[Mutator] = []
var mapMutator : Mutator
var loser = 1
var p1points = 0
var p2points = 0
var infectedMaps = false
var round = 0
var rounds = 5
var starterPowerUps = 0
var roundEndMutators = true
var level = 0
var finish_time = 0

#parkour
var parkour_levels = 13

#COLLISION LAYERS: 
#1 - p1 
#2 - p2
#3 - floor
#4 - one-way floor

#map valasztashoz
var map_paths = [
	"res://maps/showdown_maps/map1.tscn",
	"res://maps/showdown_maps/map2.tscn",
	"res://maps/showdown_maps/map3.tscn",
	"res://maps/showdown_maps/trampoline_map_1.tscn",
	"res://maps/showdown_maps/trampoline_map_2.tscn",
	"res://maps/showdown_maps/trampoline_map_3.tscn",
	"res://maps/showdown_maps/spike_map_1.tscn"
]


#mutatorhoz
enum Rarity {common, uncommon, rare}
enum Gamemode {classic, draft, infected, custom, parkour}
var chosen_gamemode : Gamemode
var customInfected = false

func newGame():
	round = 0
	p1points = 0
	p2points = 0
	p1mutators = []
	p2mutators = []
	match chosen_gamemode:
		Gamemode.classic:
			starterPowerUps = 0
			rounds = 7
			infectedMaps = false
			roundEndMutators = true
			next_round()
		Gamemode.draft:
			starterPowerUps = 4
			rounds = 5
			infectedMaps = false
			roundEndMutators = false
		Gamemode.infected:
			starterPowerUps = 0
			rounds = 7
			infectedMaps = true
			roundEndMutators = true

	if starterPowerUps > 0:
		get_tree().change_scene_to_file("res://UI/draft_scene.tscn")
	else:
		next_round()
		
func newMapMutator():
	var keys = Mutator_Library.all_mutators.keys()
	keys.shuffle()
	mapMutator = Mutator_Library.all_mutators[keys[0]]
	print("a map mutatora: "+ mapMutator.name)


func setGamemode(mode : Gamemode):
	chosen_gamemode = mode

func setp1Color(color):
	p1color = color
	
func setp2Color(color):
	p2color = color

func i_lost(_loser : int):
	loser = _loser
	if loser == 1:
		p2points+=1
	else:
		p1points += 1
	winnerText = "Player "+( "1" if _loser == 2 else "2" )+ " won!"
	if p1points >= (rounds/2+1) or p2points >= (rounds/2+1):
		#end game stuff
		end_game_stuff()
		get_tree().change_scene_to_file("res://UI/end_screen.tscn")
		return
	
	if roundEndMutators:
		get_tree().change_scene_to_file("res://UI/select_mutator.tscn")
	else:
		get_tree().change_scene_to_file("res://UI/end_round.tscn")




func end_game_stuff():
	roundEndMutators = true
	infectedMaps = false
	starterPowerUps = 0
	rounds = 5

func next_round():
	round += 1
	get_tree().change_scene_to_file("res://platform.tscn")
