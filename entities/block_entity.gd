class_name BlockEntity
extends Entity

func on_ready() -> void:
	if has_component(BlockTransformComponent):
		var transform := get_component(BlockTransformComponent) as BlockTransformComponent
		var adjacent := find_adjacent_blocks(transform.position)

		for pos in adjacent:
			var bid := adjacent[pos]
			# TODO: hack
			if bid in [4, 5]:
				print("Found adjacent machine/cable at %s" % pos)

		if has_component(MachineComponent):
			var statuslabel := Label3D.new()
			var itemlabel := Label3D.new()
			
			add_child(statuslabel)
			add_child(itemlabel)

			statuslabel.global_position = Vector3(transform.position) + Vector3(0.6, 2, 0.5)
			statuslabel.pixel_size = 0.01
			statuslabel.text = "StatusLabel"
			statuslabel.name = "StatusLabel"

			itemlabel.global_position = Vector3(transform.position) + Vector3(0.6, 0.5, 1.5)
			itemlabel.pixel_size = 0.01
			itemlabel.text = "Itemlabel"
			itemlabel.name = "ItemLabel"

func find_adjacent_blocks(pos: Vector3i) -> Dictionary[Vector3i, int]:
	var adjacent: Dictionary[Vector3i, int]
	
	var dirs := [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.FORWARD, Vector3i.BACK]
	
	for dir in dirs:
		var bloc := Global.current_terrain.get_voxel_tool().get_voxel(pos+dir)
		adjacent[pos+dir] = bloc
	
	return adjacent