extends CharacterBody2D

#FRAME IMPLEMENTATION STUFF
var last_processed_frame : int = -1
var current_attack : AttackData = null
var current_attack_frame : int = -1
var frames_before_disabling_one_way_collision = 0
var time_before_disabling_one_way_collision = 6

const FPS = 60.0

func update_frame(global_frame : int):
	if last_processed_frame == -1:
		last_processed_frame = global_frame
		return
	#checking that actually 1 frame passed
	var passed_frames = global_frame - last_processed_frame
	last_processed_frame = global_frame
	for i in range(passed_frames):
		process_single_frame()

func process_single_frame():
	#check for attack (rn only thing)
	for key in inputBuffers.keys():
		if inputBuffers[key] > 0:
			inputBuffers[key] -= 1
	if poison_frames > 0:
		poison_frames -= 1
		if poison_frames == 0:
			take_off_poision()
	if poison_wait_frames > 0:
		poison_wait_frames -= 1
		if poison_wait_frames == 0 and poisonsToBeAdded > 0:
			apply_poison(poisonDamage)
	if frames_before_disabling_one_way_collision > 0:
		frames_before_disabling_one_way_collision -= 1
		if frames_before_disabling_one_way_collision == 0:
			collision_mask &= ~(1 << 3)
	#STUN IS HERE
	if stun_frames > 0:
		process_stun_frame()
		return
	if slow_frames > 0:
		# TODO: add slow effect
		slow_frames -= 1
		if slow_frames == 0:
			speed = mySpeed
	
	if current_attack:
		process_attack_frame()
	if dash_frames > 0:
		process_dash_frame()
	process_frame_timers()
	if sting_frames > 0:
		sting_frames -= 1
	if before_sting_frames > 0: #BEING stung
		process_being_stung()
	#gravity
	var gravity_per_frame = get_gravity() / FPS
	#TODO: test if i stay on one way platform, do i get rlly high gravity?
	if not is_on_floor() and currentState != PlayerState.Dash:
			velocity += gravity_per_frame * gravityMultiplier * (2 if down else 1)
	#check for airborne
	if on_floor:
		$legs.disabled = false
		jumpCount = 0
		nairCount = 0
	else:
		$legs.disabled = true
	#jump
	if inputBuffers["p"+str(player_id)+"jump"] > 0 and jumpCount < maxJumps and currentState != PlayerState.Attack:
		inputBuffers["p"+str(player_id)+"jump"] = 0
		#TODO if vel.y > 0 => ve.y = 0; vel.y += jump force
		velocity.y = jump_force
		jumpCount+=1
	#get direction
	var direction = 0
	if usingController:
		direction = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)
	else:
		direction = Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right")
	
	#movement
	if canDash and inputBuffers["p"+str(player_id)+"dash"] > 0 and currentState != PlayerState.Dash and currentState != PlayerState.Attack:
		inputBuffers["p"+str(player_id)+"dash"] = 0
		knock_back_frames = 0
		dash()
		return
	if (direction > contiDeadzone or direction < (-1*contiDeadzone)) and canMove:
		sprite.scale.x = -1 if direction < 0 else 1
		facingLeft = direction <= 0
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, FPS)
	
	if knock_back_frames> 0:
		knock_back_frames -= 1
		velocity = trampoline_force
	
	update_state(direction)

func update_attack_sprite():
	if current_attack and current_attack.attack_anim:
		var sprite = current_attack.attack_anim.get_sprite_for_frame(current_attack_frame)
		if sprite:
			$Sprite2D.texture = sprite
func process_stun_frame():
	stun_frames -= 1
	
	velocity.x = move_toward(velocity.x, 0, 1000/FPS)
	var gravity_per_frame = get_gravity() / FPS
	
	velocity += gravity_per_frame * gravityMultiplier
	
	if stun_frames == 0:
		end_stun()

func process_attack_frame():
	current_attack_frame += 1
	update_attack_sprite()
	var fd = current_attack.attack_anim.frame_data
	# TODO: USE current_attack variable and change hierarchy in karakter body like: area2D: atackname/ collision_shape: number => how many attack sprites? > dynamic change
	var phase = fd.get_phase(current_attack_frame)
	var has_hitbox = current_attack.attack_anim.get_hitbox_index_for_frame(current_attack_frame) >= 1
	if has_hitbox:
		enable_hitbox_for_attack(current_attack.name, current_attack_frame)
	else:
		disable_hitboxes()
	var force = current_attack.attack_anim.get_movement_for_frame(current_attack_frame)
	if force != Vector2.ZERO:
		velocity.x = force.x * (-1 if facingLeft else 1)
		velocity.y = force.y

	if current_attack_frame > fd.total:
		end_attack()

func process_dash_frame():
	dash_frames -=1
	if dash_frames == 0:
		canDash = true


func process_being_stung():
	before_sting_frames -=1
	if before_sting_frames == 0:
		stings_to_apply -=1
		change_state(PlayerState.Hurt, "hurt")
		stun_frames = 15
		velocity = Vector2(0,velocity.y)
		if stings_to_apply > 0:
			before_sting_frames = waitTimeBeforeSting

func start_attack(name : String):
	print("attack start")
	anim_player.stop()
	if not canAttack or null != current_attack:
		print("ERROR at start_attack")
		return
	current_attack = attacks[name]
	current_attack_frame = 0
	canAttack = false
	
	#anim_player.play(name)
	
	print("attack started! ", name)
# TODO:  TEST, convert stun/dash to frame 
func get_next_attack(attack : AttackData) -> String:
	if current_attack.next_attack == "active":
		print("active inputting")
		var side = get_active_input()
		print(attack.name + side)
		current_attack = null
		hit_something = false
		return attack.name + side
	var holder = current_attack.next_attack
	current_attack = null
	hit_something = false
	return holder


func end_attack():
	canAttack = true
	current_attack_frame = -1
	
	if current_attack.next_attack != "" and hit_something:
		var next_attack = get_next_attack(current_attack)
		start_attack(next_attack)
		return
	hit_something = false
	current_attack = null
	canMove = true
	
	disable_hitboxes()
	if (velocity.x != 0):
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")

func enable_hitbox_for_attack(attack_name: String, frame_in_attack: int):
	# Get the AttackAnimation for this attack
	var attack = attacks[attack_name]
	if not attack.attack_anim.frame_data.is_in_active(frame_in_attack):
		return
	var anim : AttackAnimation = attack.attack_anim
	
	# Ask the animation: "Which hitbox should be active for this frame?"
	var hitbox_index = anim.get_hitbox_index_for_frame(frame_in_attack)
	
	if hitbox_index >= 1:
		disable_hitboxes()

		var hitbox_path = "Sprite2D/{0}/{1}".format([attack_name, hitbox_index])
		var hitbox = get_node(hitbox_path)
		if hitbox:
			hitbox.disabled = false
			hitbox.get_parent().monitoring = true

func process_frame_timers():
	pass

func end_stun():
	canMove = true
	canAttack = true
	hit_something = false
	facingLeft = !facingLeft
	sprite.scale.x = -1 if facingLeft else 1
	if abs(velocity.x) > 0.3 and usingController:
		change_state(PlayerState.Run, "run")
	elif abs(velocity.x) > 0 and not usingController:
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")


@export var mutator_box_scene: PackedScene
@export var player_id = 1
@onready var label = $CanvasLayer/Label
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var floor_raycasts = [$RayCast2D, $RayCast2D2]


func _ready() -> void:
	change_state(PlayerState.Idle, "idle")
	add_to_group("players")
	add_to_group("player"+str(player_id))
	label.text = "Player "+str(player_id)+" HP: "+str(hp)
	inputBuffers = {
	("p"+str(player_id)+"attack") : 0,
	("p"+str(player_id)+"dash") : 0,
	("p"+str(player_id)+"jump") : 0,
	("p"+str(player_id)+"heavy") : 0
	}
	#controllers
	var controllers = Input.get_connected_joypads()
	if controllers.size() >= player_id:
		controller_id = controllers[player_id-1] 
		usingController = true
	inputs = {
		"attack" : JOY_BUTTON_X,
		"jump" : JOY_BUTTON_A,
		"dash" : JOY_BUTTON_LEFT_SHOULDER,
		"heavy" : JOY_BUTTON_Y
		}
	if player_id == 1:
		$CanvasLayer.layer = 2
		color = Szorp.p1color
		apply_mutators(Szorp.p1mutators)
	else:
		$CanvasLayer/Label.global_position.y += 40
		$CanvasLayer/Mutators.global_position.y += 50
		color = Szorp.p2color
		apply_mutators(Szorp.p2mutators)
	mySpeed = speed
	sprite.self_modulate = color
	attacks = {
		"sword_side" : AttackData.new("sword_side", 1,Vector2(400,-100), AnimLibrary.anims["sword_side"]),
		"sword_neutral" : AttackData.new("sword_neutral", 1, Vector2(250, -200), AnimLibrary.anims["sword_neutral"]),
		"sword_down" : AttackData.new("sword_down", 1, Vector2(400,-250), AnimLibrary.anims["sword_down"]),
		"sword_nair" : AttackData.new("sword_nair", 1, Vector2(300, -300), AnimLibrary.anims["sword_nair"]),
		"sword_dair" : AttackData.new("sword_dair", 1, Vector2(0,250), AnimLibrary.anims["sword_dair"]),
		"sword_neutral_heavy" : AttackData.new("sword_neutral_heavy", 1, Vector2(0, -250), AnimLibrary.anims["sword_neutral_heavy"], "sword_neutral_heavy2"),
		"sword_neutral_heavy2" : AttackData.new("sword_neutral_heavy2", 1, Vector2(400, 30), AnimLibrary.anims["sword_neutral_heavy2"]),
		"sword_side_heavy" : AttackData.new("sword_side_heavy", 1, Vector2(0,-100), AnimLibrary.anims["sword_side_heavy"], "sword_side_heavy2"),
		"sword_side_heavy2" : AttackData.new("sword_side_heavy2", 1, Vector2(0,-100), AnimLibrary.anims["sword_side_heavy2"], "active"),
		"sword_side_heavy2_active1" : AttackData.new("sword_side_heavy2_active1", 1, Vector2(600, 0), AnimLibrary.anims["sword_side_heavy2_active1"]),
		"sword_side_heavy2_active2" : AttackData.new("sword_side_heavy2_active2", 1, Vector2(-600, 0), AnimLibrary.anims["sword_side_heavy2_active2"]),
		"sword_down_heavy" : AttackData.new("sword_down_heavy", 1, Vector2(50, 200), AnimLibrary.anims["sword_down_heavy"]),
	}

var strength : float = 10
var defense : float = 100
# (1 + hp / defense) the knockback multiplier
var hp : float = 0
var color

#state
enum PlayerState {Idle, Run, Attack, Jump, Dash, Hurt}
var currentState: PlayerState;


var attacks = {}
var speed = 400
var canMove = true

var myColor
var facingLeft
var hurtable = true
#jumpi
var jump_force = -300.0
var maxJumps = 2
var jumpCount = 0

#conti
var inputs = {}
var usingController = false
var controller_id = -1
var contiDeadzone = 0.3

#dash
var dash_frames : int = 0
var canDash = true
var horizontalDashForce = 500
var verticalDashForce = 300
var dashCooldown : int = 60
var horizontal
var vertical
var verticalSzorzo = 1
var horizontalSzorzo = 1
# weaponing
var weapon = "sword"
var attackType
var canAttack = true;
var hit_something = false
var attackCooldown = 0.2
var missPunish = 0.2
var input_buffer_frames = 12
var justJumped = false
var inputBuffers = {}
var nairCount = 0
var maxNairs = 2
var noMultiplierAttacks = ["sword_down", "sword_heavy_neutral1", "sword_heavy_side1", "spike" ]
var stunExceptionAttacks = ["sword_down", "sword_dair", "spike"]
var noAttackAnims = ["run", "idle", "hurt", "jump", "dash"]

#stun/beung hurt
var currentForce = Vector2(0,0)
var stun_frames : int = 0

#for mutators
var gravityMultiplier = 1.0
var plusStun = 0.0

#dash mutators
var pushDodge = 0 # 400-600
var attackDodge = 0.0 # multiplier 0-2
var stunDodge = 0.0 # time 0.1-0.4
#poison
var poison = 0 # the poison you apply
var poison_length = 5 # times of dmg
var poisonsToBeAdded = 0
var poisonDamage = 0 #the poison you take as dmg
var canApplyPoison = true
#stinger
var stinger = 0
var sting_frames : int = 0
var stings_to_apply : int = 0
var before_sting_frames = 0
var waitTimeBeforeSting = 60 #1 sec between stings
var stingCooldown = 300
#slow
var slow = 0 # your slow effect
var mySpeed = speed 
var slow_frames = 0
var slow_time = 60

#one_way thingy
var down_time = 0.06 # how long to go down a one way coll
var one_way_frames = 0
var one_way_time = 6

#trampoline
var knock_back_time = 12
var knock_back_frames = 0
var trampoline_force = Vector2(0,0)

var down = false # fast fallhoz


var on_floor = true

func apply_map_mutator(mutator : Mutator):
	mutator.on_apply.call(self)

func apply_mutators(mutators):
	for mutator in mutators:
		mutator.on_apply.call(self)
		var box = mutator_box_scene.instantiate()
		box.setMutator(mutator)
		if mutator.rarity == Szorp.Rarity.common:
			box.theme = preload("res://themes/common_theme.tres")
		elif mutator.rarity == Szorp.Rarity.uncommon:
			box.theme = preload("res://themes/uncommon_theme.tres")
		elif mutator.rarity == Szorp.Rarity.rare:
			box.theme = preload("res://themes/rare_theme.tres")
		$CanvasLayer/Mutators.add_child(box)


func _input(event):
	if usingController:
		var jump = Input.is_joy_button_pressed(controller_id, inputs["jump"])
		if Input.is_joy_button_pressed(controller_id, inputs["heavy"]):
			inputBuffers["p"+str(player_id)+"heavy"] = input_buffer_frames
		if Input.is_joy_button_pressed(controller_id, inputs["attack"]):
			inputBuffers["p"+str(player_id)+"attack"] = input_buffer_frames
		if jump and not justJumped:
			inputBuffers["p"+str(player_id)+"jump"] = input_buffer_frames
		if Input.is_joy_button_pressed(controller_id, inputs["dash"]):
			inputBuffers["p"+str(player_id)+"dash"] = input_buffer_frames
		#no doublejump exhaust
		justJumped = jump
		#ONE WAY COLLISION
		if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) > contiDeadzone:
			if currentState == PlayerState.Idle or currentState == PlayerState.Run or currentState == PlayerState.Jump: 
				print("IDE MEG KELL IRNI")
		if not Input.is_joy_button_pressed(controller_id, inputs["jump"]):
			if velocity.y < 0:
				velocity.y = 0
		#fastfall
		if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) > contiDeadzone:
			down = true
		else:
			down = false
	else:
		for i in inputBuffers.keys():
			if event.is_action_pressed(i):
				inputBuffers[i] = input_buffer_frames
		#one_way_coll
		#fastfall
		if Input.is_action_just_pressed("p"+str(player_id)+"down"):
			if currentState == PlayerState.Idle or currentState == PlayerState.Run or currentState == PlayerState.Jump: 
				frames_before_disabling_one_way_collision = time_before_disabling_one_way_collision
		elif Input.is_action_just_released("p"+str(player_id)+"down"):
			collision_mask |= (1 << 3)
			frames_before_disabling_one_way_collision = 0
		if Input.is_action_pressed("p"+str(player_id)+"down"):
			down = true
		else:
			down = false
		#TODO: break jump momentum
		if Input.is_action_just_released("p"+str(player_id)+"jump"):
			if velocity.y < 0:
				velocity.y = 0

var poison_frames = 0
var poison_time = 12
var poison_wait_frames = 0
var poison_wait_time = 12
func apply_poison(dmg : float):
	print("MEGINT Print DeBUG HELL")
	poisonsToBeAdded -=1
	poison_frames = poison_time
	sprite.self_modulate = Color.GREEN
	hp += dmg
	label.text = "Player "+str(player_id)+" HP: "+str(hp)

func take_off_poision():
	poison_wait_frames = poison_wait_time
	sprite.self_modulate = color
	


func _physics_process(delta: float) -> void:
	#one way floor handling STAYS HERE
	var on_one_way_floor = false
	for ray in floor_raycasts:
		if ray.is_colliding() and velocity.y >= 0:
			var collider = ray.get_collider()
			if collider and collider.is_in_group("one_way_platforms"):
				on_one_way_floor = true 
	on_floor = on_one_way_floor or is_on_floor()

	move_and_slide()

func disable_hitboxes():
	for area in $Sprite2D.get_children():
		if area is Area2D:
			area.monitoring = false
			for child in area.get_children():
				if child is CollisionShape2D:
					child.disabled = true
	#call_deferred("_disable_deferred")

func _disable_deferred():
	for area in $Sprite2D.get_children():
		if area is Area2D:
			area.monitoring = false
			for child in area.get_children():
				if child is CollisionShape2D:
					child.disabled = true

func die():
	Szorp.i_lost(player_id)

func spike_hit():
	#hit(AttackData.new("spike", 0.5, Vector2(0,-500)), 10,0,0,0)
	return

func hit(data : AttackData, _str : int, _poison : float, _stinger : int, _slow : int)->void:
	hitCount = 0
	if not hurtable:
		return
	else:
		change_state(PlayerState.Hurt, "hurt")
		if _slow > 0:
			speed = mySpeed - _slow
			slow_frames = slow_time
		#stun mechanic
		collision_mask &= ~(1 << 3)
		one_way_frames = one_way_time
		sprite.scale.x = 1 if data.force.x > 0 else -1
		facingLeft = data.force.x < 0
		
		if data.name in noMultiplierAttacks:
			velocity = data.force
		else:
			var forceX = data.force.x * (1 + hp / defense)
			var forceY = data.force.y * (1 + hp / (defense*2))
			velocity = Vector2(forceX, forceY)
		if data.name in stunExceptionAttacks:
			stun_frames = data.attack_anim.frame_data.hitstun
		else:
			stun_frames = int(data.attack_anim.frame_data.hitstun * (1 + hp / (defense*2)))
		hp += data.damage * _str / (defense / 100)
		label.text = "Player "+str(player_id)+" HP: "+str(hp)
		if _poison != 0:
			poisonsToBeAdded = 4
			poisonDamage = _poison
			apply_poison(poisonDamage)
		if _stinger != 0:
			sting(_stinger)
		return

#TODO: STING + EVERY MUTATOR NOT WORKING


func sting(number : int):
	stings_to_apply = number
	before_sting_frames = waitTimeBeforeSting
	sting_frames = stingCooldown
	



func hit_opponent(body : Node2D, data : AttackData):
	#TODO
	var force = Vector2(data.force.x * (-1 if facingLeft else 1), data.force.y)
	# return AttackData.new(data.name, dmg, force, data.stunTime)
	body.hit(AttackData.new(data.name, data.damage, force, data.attack_anim), strength, poison, (stinger if sting_frames == 0 else 0), (1.5*slow if "heavy" in data.name else slow))



func update_state(direction: float) -> void:
	if currentState == PlayerState.Attack:
		return
	elif currentState == PlayerState.Dash:
		dash_move()
	elif inputBuffers["p"+str(player_id)+"heavy"] > 0 and canAttack:
		inputBuffers["p"+str(player_id)+"heavy"] = 0
		attack(true)
	elif inputBuffers["p"+str(player_id)+"attack"] > 0 and canAttack:
		inputBuffers["p"+str(player_id)+"attack"] = 0
		attack(false)
	elif not is_on_floor():
		change_state(PlayerState.Jump, "jump")
	elif abs(direction) > contiDeadzone:
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")
		

func change_state(new_state: PlayerState, anim_name: String):
	if currentState == new_state:
		return
	currentState = new_state
	anim_player.play(anim_name)



func trampoline(force : Vector2):
	velocity = force
	trampoline_force = force
	knock_back_frames = knock_back_time

func jump(force : Vector2) ->void:
	velocity = force

func smash():
	velocity = Vector2(250,500)

func teleport_right(i : int ):
	position.x += -i if facingLeft else i


func teleport_left(i : int ):
	position.x -= -i if facingLeft else i

func side_teleport():
	position.x += -50 if facingLeft else 50

func back_teleport():
	position.x -= -50 if facingLeft else 50

var finisher = false
var next = false
func next_finish():
	facingLeft = not facingLeft
	finisher = true


func finishing():
	var activeInput

	if usingController:
		activeInput = "left" if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) < 0 else "right"
	else:
		activeInput = "left" if Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right") < 0 else "right"
	if (facingLeft and activeInput == "left") or (not facingLeft and activeInput == "right"):
		finisher = true
		anim_player.play("sword_side_heavy_finish1")
	else:
		finisher = false
		next = true
		anim_player.play("sword_side_heavy_finish2")

func get_active_input() -> String:
	var activeInput
	print("getting active input...")
	if usingController:
		activeInput = "left" if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) < (-1 * contiDeadzone) else "right"
	else:
		activeInput = "left" if Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right") < 0 else "right"
	if (facingLeft and activeInput == "left") or (not facingLeft and activeInput == "right"):
		return "_active1"
	else:
		return "_active2"


var second = false
func down_heavy_2():
	second = true

func monitor_area2D(boo : bool):
	$Sprite2D/sword_neutral.monitoring = boo
	$Sprite2D/sword_side.monitoring = boo
	$Sprite2D/sword_down.monitoring = boo
	$Sprite2D/sword_nair.monitoring = boo
	$Sprite2D/sword_dair.monitoring = boo
	$Sprite2D/sword_heavy_neutral.monitoring = boo
	$Sprite2D/sword_heavy_side.monitoring = boo
	$Sprite2D/sword_heavy_down.monitoring = boo

func attack(heavy : bool) -> void:
	currentState = PlayerState.Attack
	
	#nagyon utalom ezt az egeszet
	#get attack type (neutral, side, down, air?)

	if is_on_floor():
		canMove = false
		if usingController:
			var y = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
			var x = abs(Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X))
			if y > contiDeadzone:
				attackType = "down"
			elif x > contiDeadzone:
				attackType = "side"
			else:
				attackType = "neutral"
		else:
			if Input.is_action_pressed("p"+str(player_id)+"down"):
				attackType = "down"
			elif Input.is_action_pressed("p"+str(player_id)+"side"):
				attackType = "side"
			else:
				attackType = "neutral"
	else: # in the air
		if usingController:
			var y = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
			var x = abs(Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X))
			if y < (-1*contiDeadzone):
				attackType = "nair"
			elif y > contiDeadzone:
				attackType = "dair"
			elif x > contiDeadzone:
				attackType = "nair"
			else:
				attackType = "nair"
		else: #keyboard
			if Input.is_action_pressed("p"+str(player_id)+"up"):
				attackType = "nair"
			elif Input.is_action_pressed("p"+str(player_id)+"down"):
				attackType = "dair"
			elif Input.is_action_pressed("p"+str(player_id)+"side"):
				attackType = "nair"
			else:
				attackType = "nair"
	if attackType == "nair":
		if nairCount >= maxNairs:
			canMove = true
			canAttack = true
			change_state(PlayerState.Jump, "jump")
			return
		nairCount += 1
	var weight = "_heavy" if heavy else ""
	var attack_data = attacks[weapon+"_"+attackType + weight] 
	var attack = weapon+"_"+attackType + weight
	start_attack(attack)



func dash_move()->void:
	velocity.x = horizontal * horizontalDashForce * horizontalSzorzo
	velocity.y = vertical * verticalDashForce * verticalSzorzo

func dash() -> void:
	canDash = false
	canMove = false
	hurtable = false
	change_state(PlayerState.Dash, "dash")
	dash_frames = int(dashCooldown * (1.2 if not is_on_floor() else 1))
	
	if usingController:
		horizontal = (1 if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) > contiDeadzone else 0) + (-1 if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) < (-1*contiDeadzone) else 0)
		vertical = (1 if (Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) > contiDeadzone) else 0) + (-1 if (Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) < (-1 * contiDeadzone)) else 0) 
		
	else:
		var right = Input.is_action_pressed("p"+str(player_id)+"right")
		var up = Input.is_action_pressed("p"+str(player_id)+"up")
		var down = Input.is_action_pressed("p"+str(player_id)+"down")
		var left = Input.is_action_pressed("p"+str(player_id)+"left")
		horizontal = (1 if right else 0) + (-1 if left else 0)
		vertical = (-1 if up else 0) + (1 if down else 0)
	var supper = 0
	if horizontal == 0 and vertical == 0:
		supper = 0.1
	
	verticalSzorzo = 1.2 if horizontal == 0 and is_on_floor() else 1
	horizontalSzorzo = 1.2 if vertical == 0 and is_on_floor() else 1
	
	
	velocity.x = (horizontal * horizontalDashForce * horizontalSzorzo)
	velocity.y = vertical * verticalDashForce *verticalSzorzo
	
	await get_tree().create_timer(anim_player.get_animation("dash").length+supper).timeout
	canMove = true
	hurtable = true
	
	#afterwork
	if is_on_floor():
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Jump, "jump")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name in noAttackAnims:
		return

	if hit_something and anim_name == "sword_side_heavy":
		anim_player.play("sword_side_heavy2")
		return
		
	
	if hit_something or attackType.contains("air"):
		canMove = true
		canAttack = true
	else:
		await get_tree().create_timer(missPunish).timeout
		canMove = true
		canAttack = true
	if (velocity.x != 0):
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")
	hit_something = false
	finisher = false
	next = false
	second = false
	hitCount = 0


func takeDamage():
	if not hurtable:
		return
	else:
		hp -=10

# AREA SIGNALS

func _on_hurt_body_entered(body: Node2D) -> void:
	takeDamage()


func _sword_neutral_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	hit_opponent(body, attacks["sword_neutral"])


func _sword_side_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	hit_opponent(body, attacks["sword_side"])


func sword_down_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	# dmg and force
	hit_opponent(body, attacks["sword_down"])
	

func sword_nair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	# dmg and force
	hit_opponent(body, attacks["sword_nair"])




func dair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	velocity.y = -300
	# dmg and force
	hit_opponent(body, attacks["sword_dair"])

func clash():
	disable_hitboxes()
	var clashForce = attacks["clash"].force
	hit(AttackData.new("clash",0,Vector2(clashForce.x * (1 if facingLeft else -1), clashForce.y)), strength, 0, 0, 0)
	


func _on_button_pressed() -> void:
	var random_key = Mutator_Library.all_mutators.keys().pick_random()
	Mutator_Library.all_mutators["Sticky Sword"].on_apply.call(self)


var hitCount = 0

func sword_heavy_neutral_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	# dmg and force
	hit_opponent(body, attacks["sword_neutral_heavy"])

func _on_sword_neutral_heavy_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	# dmg and force
	hit_opponent(body, attacks["sword_neutral_heavy2"])

func _on_sword_heavy_side_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	
	hit_opponent(body, attacks["sword_side_heavy"])
	



func _on_dodge_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	var dashIrany = Vector2(0,0)
	dashIrany = Vector2(horizontal * pushDodge * 1.2, vertical* pushDodge)
	body.hit(AttackData.new("dodge", attackDodge, dashIrany, stunDodge), strength, 0, 0, 0)



func _on_sword_heavy_down_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hit_something = true
	hit_opponent(body, attacks["sword_down_heavy"])

#PARKOUR
#mi a gyasz


func _on_one_way_pls_work_body_entered(body: Node2D) -> void:
	if body.is_in_group("one_way_platforms"):
		collision_mask &= ~(1 << 3)


func _on_one_way_pls_work_body_exited(body: Node2D) -> void:
	if body.is_in_group("one_way_platforms"):
		collision_mask |= (1 << 3)


	
