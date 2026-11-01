extends StaticBody3D


func interact(player:Node3D):
	var menu = player.get_node("CanvasLayer/ModTableMenu")
	menu.visible = true
