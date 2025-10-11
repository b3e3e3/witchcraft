class_name BlockTransformComponent
extends Component

@export var position: Vector3i
@export var facing: Vector3i

func _init(position: Vector3i = Vector3i.ZERO, facing: Vector3i = Vector3i.FORWARD):
    self.position = position
    self.facing = facing