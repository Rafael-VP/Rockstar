extends RichTextLabel

var score: int
var judgments = {"Perfect": 10, "Great": 8, "Good": 5, "Bad": 2}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	text = "[center]%s[/center]" %score


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func increase(judgment: String):
	score += judgments[judgment]
	text = "[center]%s[/center]" %score
