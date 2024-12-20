extends Control

func _ready(): 
	self.visible = false

func resume():
	get_tree().paused = false
	self.visible = false
	
func pause():
	get_tree().paused = true
	self.visible = true

func testEsc():
	if Input.is_action_just_pressed("Pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused:
		resume()

func _process(_delta):
	testEsc()

func _on_continue_button_pressed() -> void:
	resume()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
