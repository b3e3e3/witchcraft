class_name MachineSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([BlockTransformComponent])

func process(entity: Entity, delta: float) -> void:
	var transform := entity.get_component(BlockTransformComponent) as BlockTransformComponent
