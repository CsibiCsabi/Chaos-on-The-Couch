# attack_animation.gd
class_name AttackAnimation extends RefCounted

var frame_data : FrameData  # REFERENCE, not copy!
var sprites : Dictionary

func _init(p_frame_data: FrameData, startup_sprites: Array, 
		   active_sprites: Array, recovery_sprites: Array):
	frame_data = p_frame_data
	sprites = {
		"startup": startup_sprites,
		"active": active_sprites,
		"recovery": recovery_sprites
	}
	
	# ENFORCE YOUR CONSTRAINT: frames >= sprites
	assert(frame_data.startup >= startup_sprites.size(), 
		"Startup has " + str(startup_sprites.size()) + " sprites but only " + 
		str(frame_data.startup) + " frames! Add frames or remove sprites.")
	assert(frame_data.active >= active_sprites.size(), 
		"Active has too many sprites for frames!")
	assert(frame_data.recovery >= recovery_sprites.size(),
		"Recovery has too many sprites for frames!")

func get_sprite_for_frame(gameplay_frame: int) -> Texture2D:
	var phase = frame_data.get_phase(gameplay_frame)
	var phase_sprites = sprites[phase]
	
	if phase_sprites.is_empty():
		return null
	
	# Calculate frame within current phase
	var frame_in_phase : int
	var frames_in_phase : int
	
	match phase:
		"startup":
			frame_in_phase = gameplay_frame
			frames_in_phase = frame_data.startup
		"active":
			frame_in_phase = gameplay_frame - frame_data.startup
			frames_in_phase = frame_data.active
		"recovery":
			frame_in_phase = gameplay_frame - frame_data.startup - frame_data.active
			frames_in_phase = frame_data.recovery
	
	# YOUR FORMULA (works because of constraint)
	var sprite_index = (frame_in_phase * phase_sprites.size()) / frames_in_phase
	return phase_sprites[sprite_index]

func get_hitbox_index_for_frame(gameplay_frame: int) -> int:
	if not frame_data.is_in_active(gameplay_frame):
		return 0
	
	# Calculate which active sprite we're on
	var active_sprites = sprites["active"]
	if active_sprites.is_empty():
		print("ACTIVE SPRITES ARE EMPTY")
		return 0
	
	var frame_in_active = gameplay_frame - frame_data.startup
	
	# Active sprite index (0-based within active sprites)
	var active_sprite_index = (frame_in_active * active_sprites.size()) / frame_data.active
	
	# Convert to 1-based hitbox index
	return active_sprite_index + 1
