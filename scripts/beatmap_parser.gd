extends Node

class_name BeatmapParser

# Parsed data
var audio_filename = ""
var hit_objects = []

const COLUMN_COUNT = 4 

func parse_beatmap(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Beatmap not found: ", file_path)
		return false

	var current_section = ""

	while not file.eof_reached():
		var line = file.get_line().strip_edges()

		# Identify the current section
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.trim_prefix("[").trim_suffix("]")
		elif current_section == "General" and line.begins_with("AudioFilename:"):
			audio_filename = line.split(":")[1].strip_edges()
		elif current_section == "HitObjects":
			var data = line.split(",")
			if data.size() >= 3:
				var x = data[0].to_int()
				var time = data[2].to_int()
				var column = get_column_from_x(x)
				hit_objects.append({"column": column, "time": time})

	file.close()
	return true

func get_column_from_x(x: int) -> int:
	# Converts x-coordinate to column index
	return clamp(floor(x * COLUMN_COUNT / 512), 0, COLUMN_COUNT-1)
