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


func format_score(score) -> String:
	if score == 0:
		return "0000"
	elif score < 100:
		return "00" + str(score)
	elif score < 1000:
		return "0" + str(score)
	else:
		return str(score)
