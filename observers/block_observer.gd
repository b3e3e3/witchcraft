class_name BlockObserver
extends Observer

func watch() -> Resource:
	return BlockTransformComponent

func on_component_added(entity: Entity, component: Resource) -> void:
	print("Syncing position %s -> %s" % [component.position, entity.position])
	
	component.position = entity.position
	Global.current_terrain.get_voxel_tool().set_voxel_metadata(component.position, entity)


func _on_player_block_placed(where: Vector3i, what: int) -> void:
	var tarnation := [4, 5]
	if not what in tarnation: return
	
	var block := MachineEntity.new()
	block.position = where

	ECS.world.add_entity(block)
	print("Created machine entity at %s" % [where])

func _on_player_block_broken(where: Vector3i, what: int) -> void:
	var block := Global.current_terrain.get_voxel_tool().get_voxel_metadata(where) as BlockEntity
	if not block:
		push_warning("Couldn't find destroyed block entity :/")
		return

	var transform := block.get_component(BlockTransformComponent) as BlockTransformComponent
	print('Retrieved matching block metadata from %s? %s (%s, %s)' % [where, block != null and transform.position == where, transform.position, where])

	block.queue_free()
	ECS.world.remove_entity(block)
	
