extends Node2D

var hit_time: float  # When the note should reach the hit area
var target_y: float  # The Y-coordinate of the hit area
var hit_registered = false
var velocity: float

const HIT_WINDOW = 0.15  # Seconds for a valid hit window (adjust as needed)

func _ready():
	# Calculate velocity based on time to hit
	var time_to_hit = hit_time - Time.get_ticks_msec() / 1000.0
	velocity = target_y / time_to_hit

func _process(delta):
	# Move the note downward
	position.y += velocity * delta

	# If note passes the hit area and wasn't hit, register as a miss
	if position.y > target_y + 50 and not hit_registered:
		register_miss()

func is_in_hit_window() -> bool:
	# Check if the note is in the valid hit window
	var current_time = Time.get_ticks_msec() / 1000.0
	return abs(hit_time - current_time) <= HIT_WINDOW

func register_hit():
	if hit_registered:
		return
	hit_registered = true
	queue_free()  # Remove the note from the scene

func register_miss():
	print("Miss!")
	hit_registered = true
	queue_free()
