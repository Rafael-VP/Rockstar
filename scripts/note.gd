extends Node2D

@onready var combo_meter = get_node("/root/Game/ComboMeter")
@onready var judgment_meter = get_node("/root/Game/JudgmentMeter")
@onready var score_meter = get_node("/root/Game/Score")

var velocity: float  # Speed at which the note moves
var target_y: float  # Y-coordinate of the hit area
var hit_registered = false

const HIT_WINDOW_PERFECT = 0.05
const HIT_WINDOW_GOOD = 0.1
const HIT_WINDOW_MISS = 0.15

func _process(delta):
	position.y += velocity * delta

func is_in_hit_window() -> bool:
	var distance_to_hit = abs(target_y - position.y)
	return distance_to_hit / velocity <= HIT_WINDOW_MISS

func register_hit(judgment: String):
	if hit_registered:
		return
	hit_registered = true
	combo_meter.increase()
	judgment_meter.update(judgment)
	score_meter.increase(judgment)
	queue_free()

func register_miss():
	if hit_registered:
		return
	hit_registered = true
	combo_meter.miss()
	judgment_meter.update("Miss")
	queue_free()  # Destroy the note
