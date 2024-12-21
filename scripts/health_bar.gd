extends TextureProgressBar

var duration = 2.0  # Duration in seconds
var elapsed_time = 0.0  # Tracks the time elapsed

func _ready():
	value = 1  # Start at 1
	set_process(true)  # Enable processing

func _process(delta):
	if elapsed_time < duration:
		elapsed_time += delta  # Increment elapsed time
		value = lerp(1, 100, elapsed_time / duration)  # Interpolate from 1 to 100
	else:
		value = 100  # Ensure it ends at 100
		set_process(false)  # Stop processing when done

func update(amount: int):
	value += amount
