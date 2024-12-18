extends Node2D

@export var key_action: String  # Input action for this column
@onready var note_container = $NoteContainer
@onready var hit_area = $HitArea
@onready var audio_player = get_parent().get_node("AudioStreamPlayer")

# Hit windows (adjust these based on testing)
const PERFECT_WINDOW = 10.0  # Pixels
const GREAT_WINDOW = 25.0
const GOOD_WINDOW = 50.0
const BAD_WINDOW = 75.0

func spawn_note(hit_time: float):
	var note_scene = preload("res://scenes/note.tscn")
	var note = note_scene.instantiate()

	# Calculate velocity (distance/time)
	var distance = hit_area.position.y - note_container.position.y
	var time_to_hit = hit_time - (audio_player.get_playback_position() + AudioServer.get_time_since_last_mix())
	var velocity = distance / time_to_hit if time_to_hit > 0 else 0

	note.velocity = velocity
	note.target_y = hit_area.position.y
	note_container.add_child(note)

func _process(delta):
	# Check for player input
	if Input.is_action_just_pressed(key_action):
		check_for_hits()

func check_for_hits():
	for note in note_container.get_children():
		var distance = abs(note.global_position.y - hit_area.global_position.y)  # Distance to HitArea
		# print(distance)

		if distance <= PERFECT_WINDOW:
			note.register_hit("Perfect")
			return
		elif distance <= GREAT_WINDOW:
			note.register_hit("Great")
			return
		elif distance <= GOOD_WINDOW:
			note.register_hit("Good")
			return
		elif distance <= BAD_WINDOW:
			note.register_hit("Bad")
			return

	# If no note is close enough, register a Miss
	# register_miss()

func register_miss():
	print("Miss")  # Log for now, expand this to reduce score or track misses
