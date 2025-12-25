extends Node

class_name AttackAnimationLibrary

var anims = {}

func _ready() -> void:
	add_sword_anims()

func add_sword_anims():
	var weapon = "sword"
	var attack = "side"
	var startup_frames = []
	# var side = AttackAnimation.new(FrameData.new(8,5,10,20),)

#func add_single_anim
