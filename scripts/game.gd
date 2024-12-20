extends Node2D

@onready var audio_player = $AudioStreamPlayer
@onready var beatmap_dialog = $BeatmapFileDialog
@onready var columns = [$Column0, $Column1, $Column2, $Column3]
@onready var pause_menu = $PauseMenu  # Adicione isso para referenciar o menu de pausa

# Variáveis
var beatmap_parser = preload("res://scripts/beatmap_parser.gd").new()
var hit_objects = []
var paused = false

var spawn_queue = []  # Fila para os objetos de hit a serem gerados
var song_start_time = 0.0

func _ready():
	# Configurar BeatmapFileDialog
	beatmap_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	beatmap_dialog.access = FileDialog.ACCESS_RESOURCES
	beatmap_dialog.filters = ["*.osu ; osu! Beatmap Files"]

	# Abrir o diálogo de beatmap
	beatmap_dialog.popup_centered()

func start_gameplay():
	# Carregar e tocar a música
	var audio_file = "res://audio/" + beatmap_parser.audio_filename
	audio_player.stream = load(audio_file)
	await get_tree().create_timer(2.0).timeout
	audio_player.play()

	# Registrar o tempo de início da música
	song_start_time = Time.get_ticks_msec() / 1000.0

	# Copiar objetos de hit para a fila de spawn
	spawn_queue = hit_objects.duplicate()

func _process(_delta):
	# Gerar notas dinamicamente com base na posição de reprodução
	if spawn_queue.is_empty():
		return

	var current_time = (audio_player.get_playback_position() + AudioServer.get_time_since_last_mix())
	while not spawn_queue.is_empty() and spawn_queue[0]["time"] / 1000.0 <= current_time + 1.3:
		var hit_object = spawn_queue.pop_front()
		var column_index = hit_object["column"]
		var hit_time = hit_object["time"] / 1000.0
		spawn_note_in_column(column_index, hit_time)

func spawn_note_in_column(column_index: int, hit_time: float):
	var column = columns[column_index]
	column.spawn_note(hit_time, column_index)

func _on_beatmap_file_dialog_file_selected(path: String) -> void:
	# Analisar o beatmap selecionado
	if beatmap_parser.parse_beatmap(path):
		hit_objects = beatmap_parser.hit_objects
		start_gameplay()
	else:
		print("Failed to load beatmap.")
			
