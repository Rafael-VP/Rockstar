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
	column.spawn_note(hit_time, column_index)

func _on_beatmap_file_dialog_file_selected(path: String) -> void:
	# Parse the selected beatmap
	if beatmap_parser.parse_beatmap(path):
		hit_objects = beatmap_parser.hit_objects
		start_gameplay()
	else:
		print("Failed to load beatmap.")
