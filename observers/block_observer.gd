class_name BlockObserver
extends Observer

signal block_created(entity: BlockEntity, where: Vector3i) #, by: PlayerEntity)
signal block_destroyed(where: Vector3i)

func watch() -> Resource:
	return BlockTransformComponent

func on_component_added(entity: Entity, component: Resource) -> void:
	print("Syncing position %s -> %s" % [component.position, entity.position])

	component.position = entity.position
	WC.current_terrain.get_voxel_tool().set_voxel_metadata(component.position, entity)


func _on_player_block_placed(where: Vector3i, what: int) -> void:
	var block: BlockEntity
	if what == 4 or what == 5:
		block = MachineEntity.new()
	else:
		block = BlockEntity.new()

	if what == 5:
		block.add_component(CableComponent.new())

	block.position = where

	ECS.world.add_entity(block)
	print("Created block entity at %s" % [where])

	block_created.emit(block, where)

func _on_player_block_broken(where: Vector3i, what: int) -> void:
	var block := WC.current_terrain.get_voxel_tool().get_voxel_metadata(where) as BlockEntity
	if not block:
		push_warning("Couldn't find destroyed block entity :/")
		return

	var transform := block.get_component(BlockTransformComponent) as BlockTransformComponent
	print('Retrieved matching block metadata from %s? %s (%s, %s)' % [where, block != null and transform.position == where, transform.position, where])

	block.queue_free()
	ECS.world.remove_entity(block)
	block_destroyed.emit(where)
