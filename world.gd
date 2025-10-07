@tool
extends Node3D

const WorldGenerator = preload("res://world_generator.gd")

@onready var terrain: VoxelTerrain = $VoxelTerrain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain.generator = WorldGenerator.new()
