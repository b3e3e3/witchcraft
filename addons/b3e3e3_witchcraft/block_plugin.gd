@tool
extends EditorInspectorPlugin

static var block_path: String = "res://blocks"

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

static func stitch_atlas(tex_w: int = 16, tex_h: int = 16) -> AtlasTexture:
	var blocks: Array[BlockData] = get_all_blocks()
	print("Blocks: %s" % blocks.size())

	var atlas := AtlasTexture.new()

	var atlas_w: int = 1 + ceil(blocks.size() / 2)
	var atlas_h: int = 1 + ceil(blocks.size() / 2)

	print("Atlas size: %s x %s" % [atlas_w, atlas_h])

	var image_w: int = atlas_w * tex_w
	var image_h: int = atlas_h * tex_h

	var image := Image.create(image_w, image_h, true, Image.FORMAT_RGBA8)
	image.fill(Color.HOT_PINK)#TRANSPARENT)

	var last_px := 0
	var last_py := 0

	print("Creating atlas")
	for block in blocks:
		for side in block.textures:
			var tex := block.textures[side]
			var img := tex.get_image()

			var w := img.get_width()
			var h := img.get_height()
			print("Found image. Size: %s x %s" % [w, h])

			var x := last_px + tex_w
			var y := last_py + tex_h
			print("Placing image at %s x %s" % [x, y])

			last_px = x + w
			last_py = y + h
			print("Updated last position to %s x %s" % [last_px, last_py])

			for i in range(w):
				for j in range(h):
					print("Setting pixel at %s x %s" % [x + i, y + j])
					image.set_pixel(x + i, y + j, img.get_pixel(i, j))

	image.save_png("res://atlas.png")

	return atlas
