extends Node3D

var test_machines: Array[Vector3i]

const WorldGenerator = preload("res://world_generator.gd")

@onready var terrain: VoxelTerrain = $VoxelTerrain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain.generator = WorldGenerator.new()

func find_adjacent_machines(pos: Vector3i) -> Array[Vector3i]:
	var adjacent: Array[Vector3i]
	
	var dirs := [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.FORWARD, Vector3i.BACK]
	
	for dir in dirs:
		var bloc := terrain.get_voxel_tool().get_voxel(pos+dir)
		if bloc == 4:
			adjacent.append(pos+dir)
	
	return adjacent

func _on_player_block_placed(where: Vector3i, what: int) -> void:
	var tarnation := [4, 5]
	if not what in tarnation: return

	test_machines.append(where)
	print("Added machine to test machines", where)
	
	for m in find_adjacent_machines(where):
		print("Adjacent machine found at ", m)


func _on_player_block_broken(where: Vector3i, what: int) -> void:
	var idx := test_machines.find(where)
	if idx > 0:
		test_machines.remove_at(idx)
