extends VoxelGeneratorScript

const channel: int = VoxelBuffer.CHANNEL_TYPE

const AIR = 0
const GRASS = 1
const DIRT = 2
const WATER = 3

const SQUASH = 16

func _get_used_channels_mask() -> int:
	return 1 << channel

func generate_elevation(scale, origin, x, y, z) -> float:
	var FN: ZN_FastNoiseLite = ZN_FastNoiseLite.new()
	return FN.get_noise_2d((origin.x + x) *  0.03, (origin.z + z) *  0.03) * scale

func generate_peaks(scale, origin, x, y, z) -> float:
	var FN: ZN_FastNoiseLite = ZN_FastNoiseLite.new()
	return FN.get_noise_2d((origin.x + x) *  2.0, (origin.z + z) *  2.0) * scale

func generate_erosion(scale, origin, x, y, z) -> float:
	var FN: ZN_FastNoiseLite = ZN_FastNoiseLite.new()
	return FN.get_noise_2d((origin.x + x) * 0.3, (origin.z + z) * 0.3) ** 2

func generate_base_terrain(scale, origin, x, y, z) -> float:
	var FN: ZN_FastNoiseLite = ZN_FastNoiseLite.new()
	return FN.get_noise_3d((origin.x + x) * 0.5, (origin.y + y) * 0.5, (origin.z + z) * 0.5)

func _generate_block(buffer: VoxelBuffer, origin: Vector3i, lod: int) -> void:
	if lod != 0:
		return
	
	buffer.fill(AIR)
	# BaseGen.generate_block(buffer, origin, lod)

	var base_height := 30.0
	var scale := 25.0
	var size := buffer.get_size()
	
	for z in range(size.z):
		for y in range(size.y):
			for x in range(size.x):
				var elev_noise := generate_elevation(scale, origin, x, y, z)
				var peak_noise := generate_peaks(scale, origin, x, y, z)
				var eros_noise := generate_erosion(scale, origin, x, y, z)
				
				var base_noise := generate_base_terrain(scale, origin, x, y, z)

				# var depth := base_height + (base_noise + peak_noise) * (elev_noise + eros_noise)
				var elev := 0#clampf(elev_noise * 1.5, -1.0, 1.0)
				var depth := base_height
				depth += base_noise * scale
				# depth += peak_noise * eros_noise

				# depth *= elev_noise #- (scale/2)
				if depth <= (origin.y + y) + SQUASH:
					buffer.set_voxel(AIR, x, y, z)
				else:
					buffer.set_voxel(DIRT, x, y, z)
				if origin.y + y < 0:
					buffer.set_voxel(WATER, x, y, z)
