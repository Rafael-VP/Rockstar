extends Node2D

var velocity: float  # Speed at which the note moves
var target_y: float  # Y-coordinate of the hit area
var hit_registered = false

const HIT_WINDOW_PERFECT = 0.05
const HIT_WINDOW_GOOD = 0.1
const HIT_WINDOW_MISS = 0.15

func _process(delta):
	position.y += velocity * delta

	# If note passes the hit area without being hit
	if position.y >= target_y + 50 and not hit_registered:
		register_miss()

func is_in_hit_window() -> bool:
	var distance_to_hit = abs(target_y - position.y)
	return distance_to_hit / velocity <= HIT_WINDOW_MISS

func register_hit():
	if hit_registered:
		return
	hit_registered = true
	print("Hit!")
	queue_free()

func register_miss():
	hit_registered = true
	print("Miss!")
	queue_free()
