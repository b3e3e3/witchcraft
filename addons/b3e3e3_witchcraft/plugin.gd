@tool
extends EditorPlugin

var block_plugin

var plugin_path: String = get_script().resource_path.get_base_dir()

func _enable_plugin() -> void:
	print(plugin_path)

	var atlas_service := load("%s/atlas_service.gd" % plugin_path)
	add_autoload_singleton("AtlasService", "%s/atlas_service.gd" % plugin_path)
	add_tool_menu_item("Stitch block atlas", Callable(atlas_service, "stitch_atlas"))

	var library_service := load("%s/library_service.gd" % plugin_path)
	add_autoload_singleton("LibraryService", "%s/library_service.gd" % plugin_path)
	add_tool_menu_item("Build block library", Callable(library_service, "update_block_library"))

	add_autoload_singleton("WC", "%s/globals.gd" % plugin_path)

func _disable_plugin() -> void:
	remove_autoload_singleton("AtlasService")
	remove_autoload_singleton("LibraryService")
	remove_autoload_singleton("WC")

func _enter_tree() -> void:
	block_plugin = load("%s/block_plugin.gd" % plugin_path)
	add_inspector_plugin(block_plugin.new())

func _exit_tree() -> void:
	remove_tool_menu_item("Stitch block atlas")
	remove_tool_menu_item("Build block library")

	remove_inspector_plugin(block_plugin)
