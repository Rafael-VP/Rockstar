extends Control

@onready var continue_button = $ContinueButton
@onready var quit_button = $QuitButton

func _ready():
	# Verificar se os nós foram corretamente referenciados
	if continue_button == null:
		print("Erro: ContinueButton não encontrado")
	if quit_button == null:
		print("Erro: QuitButton não encontrado")
	
	# Definir texto dos botões
	continue_button.text = "Continuar"
	quit_button.text = "Sair"

func _on_ContinueButton_pressed():
	get_tree().paused = false
	self.visible = false

func _on_QuitButton_pressed():
	get_tree().quit()
