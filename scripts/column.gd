extends Node2D

@export var key_action: String  # Input action for this column

#@onready var game_node = self  # O nó 'Game' é o nó atual onde o script está anexado
@onready var note_container = $NoteContainer
@onready var hit_area = $HitArea
@onready var hit_area_sprite = $Sprite
@onready var audio_player = get_parent().get_node("AudioStreamPlayer")

# Hit windows (adjust these based on testing)
const PERFECT_WINDOW = 15.0  # Pixels
const GREAT_WINDOW = 30.0
const GOOD_WINDOW = 50.0
const BAD_WINDOW = 75.0
const MISS_WINDOW = 700

# var window_height: float = ProjectSettings.get("display/window/size/viewport_height")
var sprite_timer: float = 0.0  # Usado para controlar o tempo do sprite
var current_sprite: Sprite2D = null  # Armazenar o sprite atual para mudar o frame

func spawn_note(hit_time: float, column_index: int):
	var note_scene = preload("res://scenes/note.tscn")
	var note = note_scene.instantiate()
	var sprite = note.get_node("Sprite2D")
	sprite.frame = column_index

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
		hit_area_sprite.frame = 1
		await check_for_hits()
	
	elif Input.is_action_just_released(key_action):
		hit_area_sprite.frame = 0  # Reset sprite to "unheld" state
		
	# Check for misses
	for note in note_container.get_children():
		if note.global_position.y > MISS_WINDOW:
			note.register_miss()  # Handle the miss


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
