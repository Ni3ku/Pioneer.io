extends Node2D

@onready
var label = get_node("DiceResult")

func _on_pressed() -> void:
	var dice_result1 = randi_range(1,6)
	var dice_result2 = randi_range(1,6)
	var final = dice_result1 + dice_result2
	
	label.text = "you rolled a %d" %final
