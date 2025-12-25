extends Node

class_name FrameDataLibrary

var frames = {}

func _ready() -> void:
	add_data()

func add_data():
	var sword_side = FrameData.new(8,5,10,20)
	frames["sword_side"] = sword_side
	
