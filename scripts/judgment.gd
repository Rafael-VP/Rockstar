extends RichTextLabel

var current_timer: Timer = null
var judgments = {"Perfect": "[color=yellow]Perfect[/color]", "Great": "[color=green]Great[/color]",
				 "Good": "[color=blue]Good[/color]", "Bad": "[color=pink]Bad[/color]",
				 "Miss": "[color=red]Miss[/color]"}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update(judgment: String):
	text = "[center]%s[/center]" % judgments[judgment]

	# Cancel the previous timer if it exists
	if current_timer:
		current_timer.queue_free()

	# Create a new timer to clear the judgment
	current_timer = Timer.new()
	current_timer.wait_time = 5.0
	current_timer.one_shot = true
	current_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(current_timer)
	current_timer.start()


func _on_timer_timeout():
	# Clear the text when the timer expires
	text = ""

	# Remove the timer from the scene tree
	if current_timer:
		current_timer.queue_free()
		current_timer = null
