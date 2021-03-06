extends Control

var text = []

var textNames = []

var dialogueIter = 0
var dialogueSent = false
var dialogueSpeed = 0.05
var buffEnd = false
var nameBuffEnd = false
var nameSent = false
var connected_to_player = false

onready var textInterface = $MarginContainer/Panel/MarginContainer2/TextInterfaceEngine
onready var namesInterface = $MarginContainer/Panel/MarginContainer/Names

signal text_cleared

func _ready():
	visible = false
	connect_to_player()

func connect_to_player():
	if connected_to_player == true:
		return
	if (get_tree().get_nodes_in_group("player").size() < 1):
		connected_to_player = false
	else:
		connect("text_cleared", get_tree().get_nodes_in_group("player")[0], "_on_DialogueBox_text_cleared")
		connected_to_player = true

func _process(delta):
	connect_to_player()
	textInterface.set_state(1)
	namesInterface.set_state(1)
	if text.size() == dialogueIter:
		text.clear()
		textNames.clear()
		emit_signal("text_cleared")
		visible = false
	if text.size() > 0:
		if !dialogueSent:
			textInterface.buff_text(text[dialogueIter], dialogueSpeed)
			dialogueSent = true
			buffEnd = false
		if !nameSent:
			namesInterface.buff_text(textNames[dialogueIter], 0)
			nameSent = true
			nameBuffEnd = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if buffEnd:
			textInterface.clear_text()
			namesInterface.clear_text()
			dialogueIter += 1
			dialogueSent = false
			nameSent = false
		else:
			textInterface.set_buff_speed(0)

func parse_dialogue(json):
	var dialogue = []
	var names = []
	dialogueIter = 0
	var file = File.new()
	file.open(json, File.READ)
	var data = parse_json(file.get_as_text())
	for actor in data.actors :
		for dialogues in actor.dialogue :
			names.append(0)
			dialogue.append(0) #should give an array [0,0,0,0......0] the same size as the amount of dialogue in the JSON
	for actor in data.actors :
		for i in range (actor.dialogue.size()):
			names[actor.indices[i]] = actor.name
			dialogue[actor.indices[i]] = actor.dialogue[i]
	text = dialogue
	textNames = names
	
	#Sending the new text
	namesInterface.clear_buffer()
	namesInterface.clear_text()
	textInterface.clear_buffer()
	textInterface.clear_text()
	textInterface.buff_text(text[dialogueIter], dialogueSpeed)
	namesInterface.buff_text(textNames[dialogueIter], 0)
	dialogueSent = true
	nameSent = true
	buffEnd = false
	nameBuffEnd = false
	

func _on_TextInterfaceEngine_buff_end():
	buffEnd = true

func _on_NPC_conversation(name):
	parse_dialogue(name)
	visible = true

func _on_Names_buff_end():
	nameBuffEnd = true


func _on_BookReal_conversation(name):
	parse_dialogue(name)
	visible = true


func _on_SceneManager_conversation(name):
	parse_dialogue(name)
	visible = true
