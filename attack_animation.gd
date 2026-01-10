# attack_animation.gd
class_name AttackAnimation extends RefCounted

var frame_data : FrameData  # REFERENCE, not copy!
var sprites : Dictionary
var movement : Array
var base_path = "res://anims/attack/"
func _init(weapon_name : String, attack_name : String, p_frame_data: FrameData, _movement : Array):
	frame_data = p_frame_data
	base_path = base_path.path_join(weapon_name).path_join(attack_name)
	movement = _movement
	print("Starting sprite load...")
	load_sprites()

func load_sprites():
	sprites = {"startup" : [], "active" : [], "recovery" : []}
	
	for i in sprites.keys():
		var path = base_path.path_join(i)
		sprites[i] = load_sprites_from_folder(path)

func load_sprites_from_folder(folder : String) -> Array:
	var folder_sprites = []
	if not DirAccess.dir_exists_absolute(folder):
		print("ERROR while loading ", folder)
		return folder_sprites
	var dir = DirAccess.open(folder)
	if not dir:
		print("how did we get here??????")
		return folder_sprites
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if _validate_image(file_name):
			var full_path = folder.path_join(file_name)
			print("getting file: ", full_path)
			var texture = ResourceLoader.load(full_path)
			if texture:
				folder_sprites.append(texture)
			else:
				print("Load failed!")
		else:
			print("not img file")
		file_name = dir.get_next()
	dir.list_dir_end()
	return folder_sprites

func _validate_image(file_name : String) -> bool:
	if file_name.ends_with(".import") or file_name.begins_with("."):
		return false
	var file = file_name.get_extension().to_lower()
	return file in ["png", "jpg", "jpeg"]

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
	
	var sprite_index = (frame_in_phase * phase_sprites.size()) / frames_in_phase
	sprite_index = clampi(sprite_index, 0, phase_sprites.size() - 1)
	return phase_sprites[sprite_index]

func get_movement_for_frame(gameplay_frame : int) -> Vector2:
	if gameplay_frame >= 0 and gameplay_frame < movement.size():
		return movement[gameplay_frame]
	return Vector2.ZERO

func get_hitbox_index_for_frame(gameplay_frame: int) -> int:
	#1-
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
