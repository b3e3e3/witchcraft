@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is VoxelTerrain

func _parse_begin(object: Object) -> void:
	var button = Button.new()
	button.text = "Build Block Library from Atlas"
	button.connect("pressed", Callable(LibraryService, "update_block_library").bind(object))
	add_custom_control(button)
