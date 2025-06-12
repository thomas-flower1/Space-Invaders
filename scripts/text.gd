extends Node

const speed: float = 0.1

func draw_text(text: String, label: Label) -> void:
	'''
	Given text and the reference to a label, will draw the label character by character
	'''
	
	var text_arr: Array = text.split('')
	for c in text_arr:
		if !c == " ":
			await get_tree().create_timer(speed).timeout # wait one second
		label.text = label.text + c
	
