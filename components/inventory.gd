class_name InventoryComponent
extends Component

@export var items: Array[ItemData]

func _init(default_items: Array[ItemData] = []) -> void:
    items = default_items