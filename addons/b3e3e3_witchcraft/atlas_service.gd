class_name AtlasService
extends Node

static func get_size_in_tiles(path: String = "res://atlas.json") -> Vector2:
	var file := FileAccess.open(path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) == Error.OK:
		var data = json.data
		var atlas_size = data["size"]
		return Vector2(atlas_size[0], atlas_size[1])
	file.close()

	return Vector2(0, 0)

static func get_block_library_index(uuid: StringName, library: VoxelBlockyLibrary, library_json_path: String = "res://library.json") -> int:
	# open json file
	var file := FileAccess.open(library_json_path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) == Error.OK:
		var data = json.data
		file.close()

		var blocks = data["blocks"] as Array
		# print(blocks)
		return blocks.find_custom(func(block):
			return block["uuid"] == uuid
		)

	return 0

static func get_block_side_texture(uuid: StringName, side: Global.BlockSide, path: String = "res://atlas.json") -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) == Error.OK:
		var data = json.data
		var textures = data["textures"] as Array
		# print(textures)
		var idx = textures.find_custom(func(texture):
			# print(texture)
			return texture["uuid"] == uuid and int(texture["side"]) == side
		)
		return textures[idx] if idx >= 0 else {}
	file.close()

	return {}
