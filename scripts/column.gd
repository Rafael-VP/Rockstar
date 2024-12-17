extends Node2D

@export var column_index: int  # Index of the column (0, 1, 2, etc.)
@export var key_action: String  # Input action for this column
@export var hit_area_y: float = 900.0  # Y-coordinate for the hit area

@onready var note_container = $NoteContainer

func spawn_note(hit_time: float):
	# Load the note scene and instance it
	var note_scene = preload("res://scenes/note.tscn")
	var note = note_scene.instantiate()
	
	# Set note properties
	note.position = Vector2(0, 0)  # Spawn at top of column
	note.hit_time = hit_time
	note.target_y = hit_area_y
	
	# Add note to NoteContainer
	note_container.add_child(note)

func _process(delta):
	# Handle input for this column
	if Input.is_action_just_pressed(key_action):
		check_for_hits()

func check_for_hits():
	# Check if any notes are in the hit area
	for note in note_container.get_children():
		if note.is_in_hit_window():
			note.register_hit()
			print("Hit registered!")
			return
