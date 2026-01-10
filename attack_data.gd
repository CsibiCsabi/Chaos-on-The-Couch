class_name AttackData
var name : String
var damage: float
var force: Vector2
var attack_anim : AttackAnimation
var next_attack : String


func _init(_name: String, _damage: float, _force: Vector2, _attack_anim : AttackAnimation = null, _next : String = ""):
	name = _name
	damage = _damage
	force = _force
	attack_anim = _attack_anim
	next_attack = _next
