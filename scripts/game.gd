extends Node2D

@onready var audio_player = $AudioStreamPlayer
@onready var beatmap_dialog = $BeatmapFileDialog

@onready var columns = [$Column0, $Column1, $Column2, $Column3]

# Variables
var beatmap_parser = preload("res://scripts/beatmap_parser.gd").new()
var hit_objects = []

var spawn_queue = []  # Queue for hit objects to spawn
var song_start_time = 0.0

func _ready():
	# Set up BeatmapFileDialog
	beatmap_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	beatmap_dialog.access = FileDialog.ACCESS_RESOURCES
	beatmap_dialog.filters = ["*.osu ; osu! Beatmap Files"]

	# Open the beatmap dialog
	beatmap_dialog.popup_centered()

func start_gameplay():
	# Load and play music
	var audio_file = "res://audio/" + beatmap_parser.audio_filename
	audio_player.stream = load(audio_file)
	
	await get_tree().create_timer(2.0).timeout
	
	audio_player.play()

	# Record song start time
	song_start_time = Time.get_ticks_msec() / 1000.0 

	# Copy hit objects to the spawn queue
	spawn_queue = hit_objects.duplicate()

func _process(delta):
	# Dynamically spawn notes based on playback position
	if spawn_queue.is_empty():
		return

	var current_time = (Time.get_ticks_msec() / 1000.0) - song_start_time
	while not spawn_queue.is_empty() and spawn_queue[0]["time"] / 1000.0 <= current_time + 2.0:
		var hit_object = spawn_queue.pop_front()
		var column_index = hit_object["column"]
		var hit_time = hit_object["time"] / 1000.0
		spawn_note_in_column(column_index, hit_time)

func spawn_note_in_column(column_index: int, hit_time: float):
	var column = columns[column_index]
	var note_scene = preload("res://scenes/note.tscn")
	var note = note_scene.instantiate()
	var sprite = note.get_node_or_null("Sprite2D")

	if sprite != null:
		# Setando os frames do sprite
		match column_index:
			0:
				sprite.frame = 0 
			1:
				sprite.frame = 1
			2:
				sprite.frame = 2
			3:
				sprite.frame = 3
			_:
				sprite.frame = 0 #Default


	# Calculate velocity (distance/time)
	var distance = column.hit_area.position.y - column.note_container.position.y
	var time_to_hit = hit_time - (audio_player.get_playback_position() - AudioServer.get_time_since_last_mix())
	var velocity = distance / time_to_hit if time_to_hit > 0 else 0

	note.velocity = velocity
	note.target_y = column.hit_area.position.y
	note.position = column.note_container.position  # Start position
	column.note_container.add_child(note)

func _on_beatmap_file_dialog_file_selected(path: String) -> void:
	# Parse the selected beatmap
	if beatmap_parser.parse_beatmap(path):
		hit_objects = beatmap_parser.hit_objects
		start_gameplay()
	else:
		print("Failed to load beatmap.")
