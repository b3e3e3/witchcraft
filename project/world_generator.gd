extends VoxelGeneratorScript

const channel: int = VoxelBuffer.CHANNEL_TYPE

const AIR = 0
const GRASS = 1
const DIRT = 2
const WATER = 3

const SQUASH = 16


var FN: ZN_FastNoiseLite = ZN_FastNoiseLite.new()

func _get_used_channels_mask() -> int:
	return 1 << channel

func generate_elevation(scale, origin, x, y, z) -> float:
	var coord_scale := 0.03
	return FN.get_noise_2d((origin.x + x) *  coord_scale, (origin.z + z) *  coord_scale)

func generate_peaks(scale, origin, x, y, z) -> float:
	return FN.get_noise_2d((origin.x + x) *  2.0, (origin.z + z) *  2.0) * 20

func generate_erosion(scale, origin, x, y, z) -> float:
	var coord_scale := 0.03
	return FN.get_noise_2d((origin.x + x) * coord_scale, (origin.z + z) * coord_scale) ** 2

func generate_base_terrain(scale, origin, x, y, z) -> float:
	var coord_scale := 0.3
	return FN.get_noise_3d((origin.x + x) * coord_scale, (origin.y + y) * coord_scale, (origin.z + z) * coord_scale) ** 2

func _generate_block(buffer: VoxelBuffer, origin: Vector3i, lod: int) -> void:
	if lod != 0:
		return

	# FN.fractal_octaves = 3
	
	buffer.fill(AIR)
	# BaseGen.generate_block(buffer, origin, lod)

	var base_height := 0.0
	var scale := 120.0
	var size := buffer.get_size()
	
	for z in range(size.z):
		for x in range(size.x):
			for y in range(size.y):
				var elev_noise := generate_elevation(scale, origin, x, y, z)
				var peak_noise := generate_peaks(scale, origin, x, y, z)
				var eros_noise := generate_erosion(scale, origin, x, y, z)
				
				var base_noise := generate_base_terrain(scale, origin, x, y, z)

				# var depth := base_height + (base_noise + peak_noise) * (elev_noise + eros_noise)
				var elev := clampf(elev_noise * 1.5, -1.0, 1.0)
				var depth := base_height + elev * base_noise * scale
				depth *= peak_noise * eros_noise
				# depth *= peak_noise * eros_noise

				# depth *= elev_noise - (scale/2)
				if depth <= (origin.y + y):
					if origin.y + y < 0:
						buffer.set_voxel(WATER, x, y, z)
					else:
						buffer.set_voxel(AIR, x, y, z)
				else:
					buffer.set_voxel(DIRT, x, y, z)
