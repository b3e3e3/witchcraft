@tool
class_name BlockData
extends Resource

@export var uuid: StringName = "base:new_block"
@export var name := "Block"
@export var description := "A basic block"

@export var model: VoxelBlockyModel

@export var textures: Dictionary[WC.BlockSide, Texture2D] = {
	WC.BlockSide.FRONT: null,
	WC.BlockSide.TOP: null,
	WC.BlockSide.BOTTOM: null,
	WC.BlockSide.LEFT: null,
	WC.BlockSide.RIGHT: null,
	WC.BlockSide.BACK: null,
}
