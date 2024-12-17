extends Node2D

@onready var audio_player = $AudioStreamPlayer
@onready var beatmap_dialog = $BeatmapFileDialog

@onready var columns = [$Column0, $Column1, $Column2, $Column3]

# Variables
var beatmap_parser = preload("res://scripts/beatmap_parser.gd").new()
var hit_objects = []

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
	audio_player.play()

	# Schedule note spawning
	for hit_object in hit_objects:
		var column_index = hit_object["column"]
		var hit_time = hit_object["time"] / 1000.0  # Convert ms to seconds
		spawn_note_in_column(column_index, hit_time)

func spawn_note_in_column(column_index: int, hit_time: float):
	var column = columns[column_index]
	column.spawn_note(hit_time)


func _on_beatmap_file_dialog_file_selected(path: String) -> void:
	# Parse the selected beatmap
	if beatmap_parser.parse_beatmap(path):
		hit_objects = beatmap_parser.hit_objects
		start_gameplay()
	else:
		print("Failed to load beatmap.")
