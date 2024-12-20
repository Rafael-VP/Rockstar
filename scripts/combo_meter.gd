extends RichTextLabel

var combo: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combo = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func increase():
	combo += 1
	text = "[center]%s[/center]" % combo


func miss():
	combo = 0
	text = "[center]%s[/center]" % combo
