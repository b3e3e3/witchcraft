# class_name AtlasService
extends Node

const library_json_path: String = "res://library.json"

var block_indexes: Dictionary[StringName, int]

func _ready() -> void:
	# open json file
	var file := FileAccess.open(library_json_path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) == Error.OK:
		var data = json.data
		file.close()

		var blocks = data["blocks"] as Array
		for i in range(blocks.size()):
			var b = blocks[i]
			block_indexes[b["uuid"]] = i

		print("INDEXES\n", block_indexes)

func get_size_in_tiles(path: String = "res://atlas.json") -> Vector2:
	var file := FileAccess.open(path, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) == Error.OK:
		var data = json.data
		var atlas_size = data["size"]
		return Vector2(atlas_size[0], atlas_size[1])
	file.close()

	return Vector2(0, 0)

func get_block_library_index(uuid: StringName) -> int:
	return block_indexes[uuid] if block_indexes.has(uuid) else -1

func get_block_side_texture(uuid: StringName, side: Global.BlockSide, path: String = "res://atlas.json") -> Dictionary:
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
