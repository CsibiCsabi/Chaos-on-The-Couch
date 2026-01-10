extends Node

class_name AttackAnimationLibrary

var anims = {}

func _ready() -> void:
	add_sword_anims()

func add_sword_anims():
	var weapon = "sword"
	var attack = "side"
	var frame_data = FrameData.new(12,5,15,20)
	var movement = []
	for i in range(frame_data.startup):
		movement.append(Vector2.ZERO)
	for i in range(frame_data.active/2):
		movement.append(Vector2(500,0))
	var side = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_side"] = side
	
	attack = "neutral"
	frame_data = FrameData.new(15,4,15,20)
	movement = []
	var neutral = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_neutral"] = neutral
	
	attack = "nair"
	frame_data = FrameData.new(12, 12, 9, 15)
	movement = []
	for i in range(frame_data.startup):
		movement.append(Vector2.ZERO)
	for i in range(frame_data.active):
		movement.append(Vector2(0,-200))
	var anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_nair"] = anim
	
	attack = "dair"
	frame_data = FrameData.new(9,6,9,12)
	movement = []
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_dair"] = anim
	
	attack = "neutral_heavy"
	frame_data = FrameData.new(15, 6, 8, 18)
	movement = []
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_neutral_heavy"] = anim
	
	attack = "neutral_heavy2"
	frame_data = FrameData.new(24, 6, 8, 25)
	movement = []
	for i in range(frame_data.startup/3):
		movement.append(Vector2.ZERO)
	for i in range(frame_data.startup/3):
		movement.append(Vector2(0,-150))
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_neutral_heavy2"] = anim
	
	attack = "side_heavy"
	frame_data = FrameData.new(24, 6, 8, 25)
	movement = []
	for i in range(frame_data.startup):
		movement.append(Vector2.ZERO)
	for i in range(3):
		movement.append(Vector2(700,0))
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_side_heavy"] = anim
	
	attack = "side_heavy2"
	frame_data = FrameData.new(6, 30, 1, 24)
	movement = []
	for i in range(frame_data.startup):
		movement.append(Vector2.ZERO)

	var active_count = 6
	for i in range(frame_data.active/active_count):
		movement.append(Vector2(-700,0))
	for i in range(frame_data.active/active_count):
		movement.append(Vector2(0,0))
	for i in range(frame_data.active/active_count):
		movement.append(Vector2(700,0))
	for i in range(frame_data.active/active_count):
		movement.append(Vector2(0,0))
	for i in range(frame_data.active/active_count):
		movement.append(Vector2(-700,0))
	for i in range(frame_data.active/active_count):
		movement.append(Vector2(0,0))
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_side_heavy2"] = anim
	
	attack = "side_heavy2_active1"
	frame_data = FrameData.new(5, 6, 8, 25)
	movement = []
	for i in range(frame_data.startup):
		movement.append(Vector2.ZERO)
	for i in range(frame_data.active):
		movement.append(Vector2(700,0))
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_side_heavy2_active1"] = anim
	
	attack = "side_heavy2_active2"
	frame_data = FrameData.new(15, 6, 8, 25)
	movement = []
	for i in range(frame_data.startup/2):
		movement.append(Vector2.ZERO)
	for i in range(frame_data.startup/2):
		movement.append(Vector2(700,0))
	for i in range(frame_data.active):
		movement.append(Vector2(-700,0))
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_side_heavy2_active2"] = anim
	
	
	
	
	attack = "down_heavy"
	frame_data = FrameData.new(24, 12, 16, 25)
	movement = []
	for i in range(frame_data.startup/2):
		movement.append(Vector2.ZERO)
	for i in range(2):
		movement.append(Vector2(0,-300))
	anim = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_down_heavy"] = anim
	attack = "down"
	frame_data = FrameData.new(12,5,15,20)
	movement = []
	var down = AttackAnimation.new(weapon, attack, frame_data, movement)
	anims["sword_down"] = down
#func add_single_anim
