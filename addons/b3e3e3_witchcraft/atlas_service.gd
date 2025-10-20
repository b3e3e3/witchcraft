# class_name AtlasService
@tool
extends Node

const library_json_path: String = "res://library.json"
const block_path: String = "res://blocks"
const atlas_path: String = "res://atlas.png"
const atlas_json_path: String = "res://atlas.json"

var block_indexes: Dictionary[StringName, int]

func _ready() -> void:
	build_block_indexes()

func build_block_indexes() -> void:
	print("[AtlasService]: Getting indexes")
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

func get_size_in_tiles(path: String = atlas_json_path) -> Vector2:
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

func get_block_side_texture(uuid: StringName, side: WC.BlockSide, path: String = atlas_path) -> Dictionary:
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


static func get_all_blocks(path: String = block_path) -> Array[BlockData]:
	var blocks: Array[BlockData] = []

	print("Opening dir %s" % path)
	var dir = DirAccess.open(path)

	dir.list_dir_begin()

	var file_name = dir.get_next()
	print("Filename: %s" % file_name)
	while file_name != "":
		var file_path = path + "/" + file_name
		print("Next file path: %s" % file_path)
		if dir.current_is_dir():
			blocks += get_all_blocks(file_path)
		else:
			print("Loading file %s" % file_path)
			var block = load(file_path)
			if block is BlockData:
				print("Loaded block %s" % block.name)
				blocks.append(block as BlockData)
		file_name = dir.get_next()
	return blocks

static func stitch_atlas(path: String = atlas_path, tex_w: int = 16, tex_h: int = 16) -> AtlasTexture:
	var blocks: Array[BlockData] = get_all_blocks()
	print("Blocks: %s" % blocks.size())

	var atlas := AtlasTexture.new()

	var tex_count := 0
	for block in blocks:
		tex_count += block.textures.size()

	assert(tex_count > 0, "No textures found")

	var atlas_w: int = ceil(tex_count / 2)
	var atlas_h: int = ceil(tex_count / 2)

	var image_w: int = atlas_w * tex_w
	var image_h: int = atlas_h * tex_h
	print("Image size: %s x %s (%s x %s)" % [image_w, image_h, atlas_w, atlas_h])

	var image := Image.create(image_w, image_h, true, Image.FORMAT_RGBA8)
	image.fill(Color.HOT_PINK)#TRANSPARENT)

	var atlas_json := {
		"uuid": "atlas",
		"texture_size": [tex_w, tex_h],
		"textures": [],
		"size": [atlas_w, atlas_h],
	}

	var next_px := 0
	var next_py := 0

	var images: Array[Image] = []

	print("Creating atlas")
	for block in blocks:
		for side in block.textures:
			var tex := block.textures[side]
			if tex == null: continue
			var tex_already_exists := false
			for t in atlas_json["textures"]:
				print(t)
				print(tex.resource_path)
				if t["texture"] == tex.resource_path:
					print("Texture already exists in atlas")
					tex_already_exists = true
					next_px = t["position"][0]
					next_py = t["position"][1]
					continue

			var img := tex.get_image()

			assert(img.get_width() == tex_w and img.get_height() == tex_h, "Block (%s) texture size mismatch" % block.uuid)


			var w := img.get_width()
			var h := img.get_height()
			print("Found image. Size: %s x %s" % [w, h])

			var block_json := {
				"uuid": block.uuid,
				"side": side,
				"texture": tex.resource_path,
				"position": [next_px, next_py],
				# "size": [w, h]
			}

			atlas_json["textures"].append(block_json)
			print("Added %s to atlas JSON" % block.uuid)

			var x := next_px * tex_w
			var y := next_py * tex_h
			print("Placing image at %s x %s" % [x, y])

			for i in range(tex_w):
				for j in range(tex_h):
					# avoid placing textures diagonally
					image.set_pixel(x + i, y + j, img.get_pixel(i, j))

			if next_px < atlas_w:
				next_px += 1
			elif next_py < atlas_h:
				next_py += 1
				next_px = 0

			print("Done. Updated next position to %s x %s" % [next_px, next_py])

	var editor_filesystem := EditorInterface.get_resource_filesystem()

	var file = FileAccess.open(atlas_json_path, FileAccess.WRITE)
	if file:
		if file.store_string(JSON.stringify(atlas_json)):
			editor_filesystem.reimport_files([atlas_json_path])
			print("Reimported atlas json")
		file.close()
	else:
		print("Error opening file for writing.")

	if image.save_png(path) == Error.OK:
		editor_filesystem.reimport_files([path])
		print("Reimported atlas png")

	return atlas
