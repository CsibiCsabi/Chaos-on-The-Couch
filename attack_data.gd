class_name AttackData
var name : String
var damage: float
var force: Vector2
var frame_data : FrameData
var attack_anim : AttackAnimation


func _init(_name: String, _damage: float, _force: Vector2, _frame_data: FrameData = null, _attack_anim : AttackAnimation = null):
	name = _name
	damage = _damage
	force = _force
	frame_data = _frame_data
	attack_anim = _attack_anim
