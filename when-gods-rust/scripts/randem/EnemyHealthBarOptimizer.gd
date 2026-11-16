extends Node

@export var near_distance: float = 25.0
@export var scan_interval: float = 0.25

var _player: Node3D
var _scan_left: float = 0.0

func _process(delta: float) -> void:
	_scan_left -= delta
	if _scan_left > 0.0:
		return
	_scan_left = scan_interval
	_scan()

func _scan() -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("Player") as Node3D
	
	var player_pos: Vector3 = _player.global_position if is_instance_valid(_player) else Vector3.ZERO
	var near_sq: float = near_distance * near_distance

	for node in get_tree().get_nodes_in_group("Enemy"):
		if not node is Node3D:
			continue
		
		var body = node as Node3D
		var viewport = body.find_child("SubViewport", true, false) as SubViewport
		if viewport == null:
			continue
		
		var near = is_instance_valid(_player) and body.global_position.distance_squared_to(player_pos) <= near_sq

		if near:
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
