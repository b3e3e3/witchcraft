extends Node3D

const WorldGenerator = preload("res://world_generator.gd")

@onready var terrain: VoxelTerrain = $VoxelTerrain

@onready var world: World = $World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_terrain = terrain

	# ecs setup
	ECS.world = world

	ECS.world.add_system(MachineSystem.new())

	terrain.generator = WorldGenerator.new()

func _process(delta):
	if ECS.world:
		ECS.process(delta)

func _on_player_block_placed(where: Vector3i, what: int) -> void:
	var tarnation := [4, 5]
	if not what in tarnation: return

	# create entity?
	var block := BlockEntity.new()
	block.add_components([
		BlockTransformComponent.new(where)
	])
	add_child(block)
	ECS.world.add_entity(block)
	print("Created block entity at %s" % [where])

	terrain.get_voxel_tool().set_voxel_metadata(where, block)


func _on_player_block_broken(where: Vector3i, what: int) -> void:
	var block := terrain.get_voxel_tool().get_voxel_metadata(where) as BlockEntity
	if not block:
		push_warning("Couldn't find destroyed block entity :/")
		return
	
	var component := block.get_component(BlockTransformComponent) as BlockTransformComponent
	print('Retrieved matching block metadata from %s? %s (%s, %s)' % [where, block != null and component.position == where, component.position, where])

	block.queue_free()
	ECS.world.remove_entity(block)
