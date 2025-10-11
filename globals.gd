extends Node

enum BlockSide {
	LEFT	=  1,
	RIGHT	= ~1,
	FRONT	=  2,
	BACK	= ~2,
	TOP	 	=  3,
	BOTTOM	= ~3,
}

func get_enum_key(value: Variant, _enum):
    return _enum.keys()[_enum.values().find(value)]

func get_side_name(side: BlockSide):
    return get_enum_key(side, BlockSide)