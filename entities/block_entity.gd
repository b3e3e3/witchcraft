class_name BlockEntity
extends Entity

var position: Vector3i

func define_components() -> Array:
	return [
		BlockTransformComponent.new()
	]

func find_adjacent_blocks() -> Array[BlockEntity]:
	var transform := get_component(BlockTransformComponent) as BlockTransformComponent
	if not transform: return []
	
	var pos := transform.position

	var adjacent: Array[BlockEntity]

	for block_pos in find_adjacent_voxels(pos):
		var metadata = Global.voxel_tool.get_voxel_metadata(block_pos)
		if metadata is BlockEntity:
			var block := metadata as BlockEntity
			print("Found block entity at %s" % block_pos)
			adjacent.append(block)

	return adjacent

func find_adjacent_voxels(pos: Vector3i) -> Dictionary[Vector3i, int]:
	var adjacent: Dictionary[Vector3i, int]
	
	var dirs := [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.FORWARD, Vector3i.BACK]
	
	for dir in dirs:
		var block := Global.voxel_tool.get_voxel(pos+dir)
		adjacent[pos+dir] = block
	
	return adjacent