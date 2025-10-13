class_name BlockObserver
extends Observer

func watch() -> Resource:
    return BlockTransformComponent

func on_component_added(entity: Entity, component: Resource) -> void:
    print("Syncing position %s -> %s" % [component.position, entity.position])
    component.position = entity.position