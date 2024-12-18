extends Node2D

@export var key_action: String  # Input action for this column
@onready var note_container = $NoteContainer
@onready var hit_area = $HitArea
@onready var audio_player = get_parent().get_node("AudioStreamPlayer")

#var note_spawn_y: float = -500.0  # Position above the screen

var window_height: float = ProjectSettings.get("display/window/size/viewport_height")

#func _ready():
	# Position hit area dynamically near the bottom of the screen
	#hit_area_y = window_height - 100
	#hit_area.position = Vector2(0, hit_area_y)
	# hit_area_y = hit_area.position.y

	# Position note container at spawn location
	# note_container.position = Vector2(0, note_spawn_y)

func spawn_note(hit_time: float):
	var note_scene = preload("res://scenes/note.tscn")
	var note = note_scene.instantiate()

	# Calculate velocity (distance/time)
	var distance = hit_area.position.y - note_container.position.y
	var time_to_hit = hit_time - audio_player.get_playback_position()
	var velocity = distance / time_to_hit if time_to_hit > 0 else 0

	note.velocity = velocity
	note.target_y = hit_area.position.y
	note.position = note_container.position  # Start position
	note_container.add_child(note)

func _process(delta):
	# Check for player input
	if Input.is_action_just_pressed(key_action):
		check_for_hits()

func check_for_hits():
	for note in note_container.get_children():
		if note.is_in_hit_window():
			note.register_hit()
			return
