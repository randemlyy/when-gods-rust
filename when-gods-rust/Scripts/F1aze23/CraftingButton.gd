class_name CraftingButton 
extends Control

var hBoxC: HBoxContainer

func create(dict: Dictionary) -> void:
	hBoxC = get_node("HBoxContainer") as HBoxContainer
	if hBoxC == null:
		print("where is it")
		return
	for child in hBoxC.get_children():
		child.queue_free()
		
	for key in dict:
		var vBox := VBoxContainer.new()
		hBoxC.add_child(vBox)
		
		var res := Label.new()
		res.text = str(key)
		vBox.add_child(res)
		
		var amt := Label.new()
		amt.text = str(dict[key])
		vBox.add_child(amt)
