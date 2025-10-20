@tool
extends Node

func update_block_library(terrain: VoxelTerrain, atlas_path: String = "res://atlas.png"):
	var generator := terrain.generator
	var mesher := terrain.mesher

	terrain.material_override.albedo_texture = ResourceLoader.load(atlas_path)

	print("Got mesher and generator")
	if mesher is VoxelMesherBlocky:
		var voxel_mesher := mesher as VoxelMesherBlocky
		var library := voxel_mesher.library as VoxelBlockyLibrary
		var blocks := AtlasService.get_all_blocks()

		library.models = []

		print("Got %s block(s)" % blocks.size())

		var library_json := {
			"version": 1,
			"blocks": []
		}

		for block in blocks:
			var model = block.model
			if not model: continue

			library_json["blocks"].append({
				"uuid": block.uuid,
				"resource_path": model.resource_path,
			})

			if model is VoxelBlockyModelCube:
				var sides: Dictionary[WC.BlockSide, StringName] = {
					WC.BlockSide.LEFT: "tile_left",
					WC.BlockSide.RIGHT: "tile_right",
					WC.BlockSide.TOP: "tile_top",
					WC.BlockSide.BOTTOM: "tile_bottom",
					WC.BlockSide.FRONT: "tile_front",
					WC.BlockSide.BACK: "tile_back"
				}

				var front := AtlasService.get_block_side_texture(block.uuid, WC.BlockSide.FRONT)
				if block.uuid == "dirt":
					print("FRONT ", front)
				if front != {}:
					for side in sides:
						model[sides[side]].x = front["position"][0]
						model[sides[side]].y = front["position"][1]

						if block.textures.has(side):
							var tex := AtlasService.get_block_side_texture(block.uuid, side)
							model[sides[side]].x = tex["position"][0]
							model[sides[side]].y = tex["position"][1]

				model.atlas_size_in_tiles = AtlasService.get_size_in_tiles()
				print("Size in tiles:", model.atlas_size_in_tiles)

			library.add_model(model)

		var file = FileAccess.open("res://library.json", FileAccess.WRITE)
		if file:
			var editor_filesystem := EditorInterface.get_resource_filesystem()
			if file.store_string(JSON.stringify(library_json)):
				editor_filesystem.reimport_files(["res://library.json"])
				print("Reimported library json")
			file.close()
		else:
			print("Error opening file for writing.")
