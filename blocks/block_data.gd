@tool
class_name BlockData
extends Resource

@export var name := "Block"
@export var description := "A basic block"

@export var model: VoxelBlockyModel

@export var textures: Dictionary[Global.BlockSide, Texture2D] = {
	Global.BlockSide.FRONT: null,
	Global.BlockSide.TOP: null,
	Global.BlockSide.BOTTOM: null,
	Global.BlockSide.LEFT: null,
	Global.BlockSide.RIGHT: null,
	Global.BlockSide.BACK: null,
}
