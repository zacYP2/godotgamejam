extends Node2D

class_name DungeonRoom

var open_exit_directions: int = 0
enum directions { NORTH = 1, SOUTH = 2, EAST = 4, WEST = 8 }

var is_open := true setget set_is_open


signal exit_room(exit_direction)


func _ready() -> void:
	for portal in $Portals.get_children():
		portal.is_enabled = true
	for enemy in $Enemies.get_children():
		enemy.connect('enemy_dead', self, 'is_room_cleared')


func is_room_cleared() -> bool:
	yield(get_tree().create_timer(.1), 'timeout')
	if get_tree().get_nodes_in_group('Enemy').empty():
		self.is_open = true
		return true

	self.is_open = false
	return false


func get_room_enter_position(direction: int) -> Vector2:
	var exit_position: Position2D
	match direction:
		directions.NORTH:
			exit_position = $Portals/PortalNorth/ExitPoint
		directions.SOUTH:
			exit_position = $Portals/PortalSouth/ExitPoint
		directions.EAST:
			exit_position = $Portals/PortalEast/ExitPoint
		directions.WEST:
			exit_position = $Portals/PortalWest/ExitPoint
		_:
			printerr('Direction is not valid: %s' % direction)

	return exit_position.global_position


static func get_opposite_direction(direction: int) -> int:
	var opposite: int
	match direction:
		directions.NORTH:
			opposite = directions.SOUTH
		directions.SOUTH:
			opposite = directions.NORTH
		directions.EAST:
			opposite = directions.WEST
		directions.WEST:
			opposite = directions.EAST
		_:
			printerr('Direction is not valid: %s' % direction)
	return opposite


func set_is_open(_is_open: bool) -> void:
	is_open = _is_open
	for portal in $Portals.get_children():
		portal.is_open = is_open


func _on_Portal_body_entered(body: Node, direction: int) -> void:
	if body is Player:
		emit_signal('exit_room', direction)


func _on_PortalNorth_body_entered(body: Node) -> void:
	_on_Portal_body_entered(body, directions.NORTH)


func _on_PortalSouth_body_entered(body: Node) -> void:
		_on_Portal_body_entered(body, directions.SOUTH)


func _on_PortalEast_body_entered(body: Node) -> void:
		_on_Portal_body_entered(body, directions.EAST)


func _on_PortalWest_body_entered(body: Node) -> void:
		_on_Portal_body_entered(body, directions.WEST)