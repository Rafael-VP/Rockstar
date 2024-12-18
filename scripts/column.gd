extends Node2D

@export var key_action_0: String = "key0"  # Entrada para a coluna 0
@export var key_action_1: String = "key1"  # Entrada para a coluna 1
@export var key_action_2: String = "key2"  # Entrada para a coluna 2
@export var key_action_3: String = "key3"  # Entrada para a coluna 3

@onready var game_node = self  # O nó 'Game' é o nó atual onde o script está anexado
@export var key_action: String  # Input action for this column
@onready var note_container = $NoteContainer
@onready var hit_area = $HitArea
@onready var audio_player = get_parent().get_node("AudioStreamPlayer")

# Hit windows (adjust these based on testing)
const PERFECT_WINDOW = 10.0  # Pixels
const GREAT_WINDOW = 25.0
const GOOD_WINDOW = 50.0
const BAD_WINDOW = 75.0
const MISS_WINDOW = 700
var window_height: float = ProjectSettings.get("display/window/size/viewport_height")

var sprite_timer: float = 0.0  # Usado para controlar o tempo do sprite
var current_sprite: Sprite2D = null  # Armazenar o sprite atual para mudar o frame

# Precarregar a cena 'Column' para instanciar
var column_scene = preload("res://scenes/Column.tscn")

# Instanciar as colunas e adicioná-las ao nó 'Game'
var columns = []

func _ready():
	# Instanciar as 4 colunas e adicioná-las como filhos do nó Game
	for i in range(4):
		var column_instance = column_scene.instantiate()
		game_node.add_child(column_instance)
		columns.append(column_instance)
		column_instance.name = "Column" + str(i)  # Definir o nome para cada coluna

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
		
	# Check for misses
	for note in note_container.get_children():
		if note.global_position.y > MISS_WINDOW:
			note.register_miss()  # Handle the miss
	# Verifica cada ação e chama o sprite correspondente
	if Input.is_action_just_pressed(key_action_0):
		mudar_sprite("Seta0")
	elif Input.is_action_just_pressed(key_action_1):
		mudar_sprite("Seta1")
	elif Input.is_action_just_pressed(key_action_2):
		mudar_sprite("Seta2")
	elif Input.is_action_just_pressed(key_action_3):
		mudar_sprite("Seta3")

	# Verifica se o tempo do timer expirou para voltar o frame do sprite
	if current_sprite != null:
		sprite_timer -= delta
		if sprite_timer <= 0.0:
			current_sprite.frame = 0  # Retorna o frame para 0
			current_sprite = null  # Reseta o sprite

func mudar_sprite(sprite_name: String):
	# Depuração: Verifique os filhos do nó Game
	
	# Encontra o Sprite correspondente diretamente no nó 'Game'
	var sprite = game_node.get_node_or_null(sprite_name)  # Buscar diretamente o Sprite no nó Game
	
	if sprite:
		# Muda o frame para 1
		sprite.frame = 1
		# Configura o tempo para voltar ao frame 0 após 0.1 segundos
		sprite_timer = 0.1
		current_sprite = sprite  # Armazenar o sprite para controlá-lo no _process

func check_for_hits():
	for note in note_container.get_children():
		var distance = abs(note.global_position.y - hit_area.global_position.y)  # Distance to HitArea

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
