extends Node3D

const WorldGenerator = preload("res://world_generator.gd")

@onready var terrain: VoxelTerrain = $VoxelTerrain

@onready var world: World = $World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain.generator = WorldGenerator.new()
	Global.current_terrain = terrain

	ECS.world = world

func _process(delta):
	if ECS.world:
		ECS.process(delta)

# func _on_player_block_placed(where: Vector3i, what: int) -> void:
	# TODO: bug found in GECS?
	# Entity.on_ready() does NOT fire after waiting for component_added
	# all the stuff like add child, set metadata, etc., were all happening AFTER the await before
	# but now, they are before to make sure Entity.on_ready() fires. why??
	# await block.component_added

	# block_tsf.position = where

