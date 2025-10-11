class_name BlockEntity
extends Entity

func on_ready() -> void:
	if has_component(BlockTransformComponent):
		var transform := get_component(BlockTransformComponent) as BlockTransformComponent
		var adjacent := find_adjacent_blocks(transform.position)
		
		var tarnation := [4, 5]

		for pos in adjacent:
			var bid := adjacent[pos]
			# TODO: hack
			if bid in tarnation:
				print("Found adjacent machine/cable at %s" % pos)

func find_adjacent_blocks(pos: Vector3i) -> Dictionary[Vector3i, int]:
	var adjacent: Dictionary[Vector3i, int]
	
	var dirs := [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.FORWARD, Vector3i.BACK]
	
	for dir in dirs:
		var bloc := Global.current_terrain.get_voxel_tool().get_voxel(pos+dir)
		adjacent[pos+dir] = bloc
	
	return adjacent