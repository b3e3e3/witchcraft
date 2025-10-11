class_name BlockTransformComponent
extends Component

@export var position: Vector3i
@export var facing: Vector3i

func _init(block_position: Vector3i = Vector3i.ZERO, block_facing: Vector3i = Vector3i.FORWARD):
    self.position = block_position
    self.facing = block_facing