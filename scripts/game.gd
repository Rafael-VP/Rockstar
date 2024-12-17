extends Node2D

# Beatmap parser
var beatmap_parser: BeatmapParser
var beatmap_path: String = ""  # Path to selected beatmap file

# Nodes
@onready var beatmap_file_dialog = $BeatmapFileDialog
@onready var audio_player = $AudioStreamPlayer
@onready var columns = [$Column0, $Column1, $Column2, $Column3]

func _ready():
	beatmap_parser = BeatmapParser.new()
	setup_beatmap_selection()

func setup_beatmap_selection():
	# Open file dialog on startup
	beatmap_file_dialog.popup()

func _on_BeatmapFileDialog_file_selected(path):
	beatmap_path = path
	print("Selected beatmap:", beatmap_path)
	load_and_start_gameplay()

func load_and_start_gameplay():
	if beatmap_parser.parse_beatmap(beatmap_path):
		# Load and play the song
		var audio_file = "res://audio/" + beatmap_parser.audio_filename
		audio_player.stream = load(audio_file)
		audio_player.play()

		# Spawn notes for all hit objects
		for hit_object in beatmap_parser.hit_objects:
			var column = hit_object["column"]
			var time = hit_object["time"] / 1000.0  # Convert ms to seconds
			columns[column].spawn_note(time)
	else:
		print("Failed to parse beatmap.")


func _on_beatmap_file_dialog_file_selected(path: String) -> void:
	pass # Replace with function body.
