# frame_data.gd
class_name FrameData extends RefCounted

# FIGHTING GAME HOLY TRINITY
var startup : int      # Frames before hitbox
var active : int       # Frames hitbox exists  
var recovery : int     # Frames after hitbox

# HIT EFFECTS
var hitstun : int      # Opponent stun on hit

# Calculated properties
var total : int:
	get: return startup + active + recovery

var hitbox_start : int:
	get: return startup

var hitbox_end : int:
	get: return startup + active - 1

# Phase checkers
func is_in_startup(frame: int) -> bool:
	return frame < startup

func is_in_active(frame: int) -> bool:
	return frame >= startup and frame < startup + active

func is_in_recovery(frame: int) -> bool:
	return frame >= startup + active

func get_phase(frame: int) -> String:
	if is_in_startup(frame): return "startup"
	if is_in_active(frame): return "active"
	return "recovery"

func _init(p_startup = 5, p_active = 3, p_recovery = 15, 
		   p_hitstun = 18):
	startup = p_startup
	active = p_active
	recovery = p_recovery
	hitstun = p_hitstun
