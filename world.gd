extends Node3D

const WorldGenerator = preload("res://world_generator.gd")

@onready var terrain: VoxelTerrain = $VoxelTerrain

@onready var world: World = $World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain.generator = WorldGenerator.new()
	Global.current_terrain = terrain

	ECS.world = world

	# ecs systems
	ECS.world.add_system(MachineSystem.new())

	# ecs observers
	ECS.world.add_observer(BlockObserver.new())

func _process(delta):
	if ECS.world:
		ECS.process(delta)

func _on_player_block_placed(where: Vector3i, what: int) -> void:
	# TODO: associate block IDs with an entity class, maybe some kind of lookup table of references that can autofill the blocklibrary?
	var tarnation := [4, 5]
	if not what in tarnation: return

	# create entity?
	var block := MachineEntity.new()
	block.position = where
	# var block_tsf := block.get_component(BlockTransformComponent) as BlockTransformComponent

	add_child(block)

	terrain.get_voxel_tool().set_voxel_metadata(where, block)

	ECS.world.add_entity(block)
	print("Created block entity at %s" % [where])
	
	# TODO: bug found in GECS?
	# Entity.on_ready() does NOT fire after waiting for component_added
	# all the stuff like add child, set metadata, etc., were all happening AFTER the await before
	# but now, they are before to make sure Entity.on_ready() fires. why??
	# await block.component_added

	# block_tsf.position = where


func _on_player_block_broken(where: Vector3i, what: int) -> void:
	var block := terrain.get_voxel_tool().get_voxel_metadata(where) as BlockEntity
	if not block:
		push_warning("Couldn't find destroyed block entity :/")
		return
	
	var component := block.get_component(BlockTransformComponent) as BlockTransformComponent
	print('Retrieved matching block metadata from %s? %s (%s, %s)' % [where, block != null and component.position == where, component.position, where])

	block.queue_free()
	ECS.world.remove_entity(block)
