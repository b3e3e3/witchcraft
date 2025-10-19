@tool
extends EditorPlugin

var block_plugin

func _enable_plugin() -> void:
	add_autoload_singleton("AtlasService", "res://addons/b3e3e3_witchcraft/atlas_service.gd")

func _enter_tree() -> void:
	block_plugin = preload("res://addons/b3e3e3_witchcraft/block_plugin.gd")
	add_inspector_plugin(block_plugin.new())

	add_tool_menu_item("Stitch block atlas", Callable(block_plugin, "stitch_atlas"))

func _exit_tree() -> void:
	remove_inspector_plugin(block_plugin)
