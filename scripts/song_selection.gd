extends Control

@onready var song_list = $ScrollContainer/VBoxContainer
var beatmap_dir = "res://beatmaps/"
var fv

func _ready():
	fv = FontVariation.new()
	fv.set_base_font(load("res://assets/Minecraft.ttf"))
	
	load_song_list()

func load_song_list():
	var dir = DirAccess.open(beatmap_dir)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			var folder_path = beatmap_dir + folder_name
			if dir.dir_exists(folder_path):
				var osu_files = get_osu_files(folder_path)
				var image_file = get_image_file(folder_path)
				if osu_files.size() > 0:
					create_song_group(folder_path, osu_files, image_file)
			
			folder_name = dir.get_next()

func get_osu_files(folder_path: String) -> Array:
	var dir = DirAccess.open(folder_path)
	var osu_files = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".osu"):
				osu_files.append(folder_path + "/" + file_name)
			file_name = dir.get_next()
	return osu_files

func get_image_file(folder_path: String) -> String:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".jpg"):
				return folder_path + "/" + file_name  # Return first found JPG
			file_name = dir.get_next()
	return ""  # No image found


func extract_song_info(osu_path: String) -> Array:
	var file = FileAccess.open(osu_path, FileAccess.READ)
	var song_title = "Unknown Song"
	var artist = "Unknown Artist"
	var difficulty = "Unknown Difficulty"
	var overall_difficulty = 0.0
	var audio_file = ""

	if file:
		while not file.eof_reached():
			var line = file.get_line()
			if line.begins_with("Title:"):
				song_title = line.split(":", false, 1)[1].strip_edges()
			elif line.begins_with("Artist:"):
				artist = line.split(":", false, 1)[1].strip_edges()
			elif line.begins_with("AudioFilename:"):
				audio_file = line.split(":", false, 1)[1].strip_edges()
			elif line.begins_with("Version:"):
				difficulty = line.split(":", false, 1)[1].strip_edges()

			if song_title != "Unknown Song" and artist != "Unknown Artist" and difficulty != "Unknown Difficulty" and audio_file != "":
				break
	return [song_title, difficulty, audio_file, artist]

func create_song_group(folder_path: String, osu_files: Array, image_path: String):
	# Extract main song title and audio file from the first beatmap file
	var song_info = extract_song_info(osu_files[0])
	var song_title = song_info[0]
	var audio_path = folder_path + "/" + song_info[2]
	var artist = song_info[3]

	# Create a button for the song itself
	var song_button = Button.new()
	song_button.text = "[ " + song_title + " ]\n" + artist
	song_button.add_theme_font_override("font", fv)
	song_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	song_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	song_button.custom_minimum_size = Vector2(0, 100)

	# Create an HBox to hold the image and button
	var song_hbox = HBoxContainer.new()
	song_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#song_hbox.custom_minimum_size = Vector2(100, 500)

	# Add image if available
	if image_path != "":
		var texture_rect = TextureRect.new()
		texture_rect.texture = load(image_path)
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.custom_minimum_size = Vector2(150, 150)  # Fixed size for the image
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
		song_hbox.add_child(texture_rect)  # Add image to the left

	song_hbox.add_child(song_button)  # Add button next to it

	# Create a VBox to hold difficulty buttons (hidden by default)
	var difficulty_container = VBoxContainer.new()
	difficulty_container.visible = false  # Starts collapsed

	# Create difficulty buttons inside the container
	#for osu_path in osu_files:
	#	var diff_info = extract_song_info(osu_path)
	#	var difficulty_button = Button.new()
	#	difficulty_button.text = diff_info[0] + " [" + diff_info[1] + "]"
	#	difficulty_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#	difficulty_button.connect("pressed", Callable(self, "_on_song_selected").bind(osu_path, audio_path))
	#	difficulty_container.add_child(difficulty_button)

	for osu_path in osu_files:
		var diff_info = extract_song_info(osu_path)
		var difficulty_button = Button.new()
		difficulty_button.text = diff_info[0] + " [" + diff_info[1] + "]"
		difficulty_button.add_theme_font_override("font", fv)
		difficulty_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		difficulty_button.connect("pressed", Callable(self, "_on_song_selected").bind(osu_path, audio_path))
		difficulty_container.add_child(difficulty_button)

	# Connect the song button to toggle difficulties
	song_button.connect("pressed", Callable(self, "_toggle_difficulty_list").bind(difficulty_container))

	# Add both to the song list
	song_list.add_child(song_hbox)
	song_list.add_child(difficulty_container)




func _toggle_difficulty_list(difficulty_container: VBoxContainer):
	difficulty_container.visible = not difficulty_container.visible  # Toggle visibility

func _on_song_selected(osu_path: String, audio_path: String):
	print("Selected beatmap: ", osu_path)
	print("Audio file: ", audio_path)
	var beatmap_scene = load("res://scenes/game.tscn")
	var beatmap_instance = beatmap_scene.instantiate()
	beatmap_instance.initialize(audio_path, osu_path)
	get_tree().current_scene.add_child(beatmap_instance)
