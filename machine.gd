# class_name Machine
extends Node

signal world_tick
signal operate_tick
signal io_tick

# @export var voxel_pos: Vector3i

var tick_count: int = 0

const OPERATE_TICK_LENGTH: int = 96
const IO_TICK_LENGTH: int = 72