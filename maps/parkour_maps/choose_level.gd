extends Control


@export var levelTile : PackedScene
var levels = Szorp.parkour_levels
func _ready() -> void:
	for i in range(1,levels+1):
		var tile = levelTile.instantiate()
		tile.setName(str(i))
		$VBoxContainer/GridContainer.add_child(tile)
