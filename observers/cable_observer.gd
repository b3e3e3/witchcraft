class_name CableObserver
extends Observer

var astar := AStar3D.new()
var path = []

func watch() -> Resource:
	return CableComponent

func on_component_added(entity: Entity, component: Resource) -> void:
	assert(entity is BlockEntity, "Entity is not block")

	while not entity.has_component(BlockTransformComponent):
		await entity.component_added

	var blocks := traverse_cables(entity)
	calculate_cable_network(blocks)

	for b in blocks:
		if b is MachineEntity:
			var t := b.get_component(BlockTransformComponent) as BlockTransformComponent
			recalculate_path(t.position)
			break

func recalculate_path(target_position: Vector3i) -> void:
	path.clear()
	path = astar.get_point_path(0, astar.get_closest_point(target_position))
	if path.size() > 0:
		var t := Global.current_terrain.get_voxel_tool()
		print("Found path to %s" % t.get_voxel_metadata(path[0]).name)
		for i in range(path.size()):
			var p = path[i]
			if t.get_voxel(p) == 4:
				t.set_voxel(path[i-1], 2)
	

func calculate_cable_network(blocks: Array[BlockEntity]) -> void:
	for i in range(blocks.size()):
		var e := blocks[i]
		if not e.has_component(BlockTransformComponent): continue
		
		var transform := e.get_component(BlockTransformComponent) as BlockTransformComponent
		var pos := transform.position

		astar.add_point(i, pos)
		if i > 0:
			astar.connect_points(i, i-1)

func traverse_cables(entity: BlockEntity, blocks: Array[BlockEntity] = []) -> Array[BlockEntity]:
	var block_entity := entity as BlockEntity
	var adjacent: Array[BlockEntity] = block_entity.find_adjacent_blocks()

	# first, generate connections between points
	for e in adjacent:
		if not e in blocks:
			if e.has_component(CableComponent):
				blocks.append(e)
				print("Cable...")
				return traverse_cables(e, blocks)
			elif e.has_component(MachineComponent):
				blocks.append(e)
				print("Machine found!")
	
	return blocks
