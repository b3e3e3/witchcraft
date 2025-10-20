class_name ItemData
extends Resource


@export var name: String

func _init(item_name: String = "Item") -> void:
    self.name = item_name