extends Node

#region enums
enum BlockSide {
	LEFT	=  1,
	RIGHT	= ~1,
	FRONT	=  2,
	BACK	= ~2,
	TOP	 	=  3,
	BOTTOM	= ~3,
}

enum MachineAction {
	OPERATE = 0b0001,
	INPUT = 0b0010,
	OUTPUT = 0b0100,
}

enum MachineState {
	IDLE,
	ACTIVE,
}
#endregion

var current_terrain: VoxelTerrain

func get_enum_key(value: Variant, _enum):
	return _enum.keys()[_enum.values().find(value)]

func get_side_name(side: BlockSide):
	return get_enum_key(side, BlockSide)

func _process(delta: float) -> void:
	if ECS.world:
		ECS.process(delta)