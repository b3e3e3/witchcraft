class_name Machine
extends Node

signal world_tick
signal operate_tick
signal io_tick

@export var voxel_pos: Vector3i

var tick_count: int = 0

const OPERATE_TICK_LENGTH: int = 96
const IO_TICK_LENGTH: int = 72

enum State {
	IDLE,
	ACTIVE,
}
var state := State.IDLE

enum Action {
	OPERATE = 0b0001,
	INPUT = 0b0010,
	OUTPUT = 0b0100,
}

var actions: int = 0

class Item:
	var name: String = "Item"

var input_items: Array[Item] = []
var output_items: Array[Item] = []

@onready var label: Label3D = $Label3D

@export var connections: Dictionary[Global.BlockSide, Machine] = {}

func _init(voxeL_pos: Vector3i) -> void:
	self.voxel_pos = voxel_pos

func ensure_action(action: Action) -> void:
	if not actions & action: actions ^= action

func has_action(action: Action) -> bool:
	return actions & action

func remove_action(action: Action) -> void:
	if actions & action: actions &= ~action

#region tick hooks
func _on_world_tick() -> void:
	tick_count += 1
	if tick_count % OPERATE_TICK_LENGTH == 0:
		self.operate_tick.emit()
	if tick_count % IO_TICK_LENGTH == 0:
		self.io_tick.emit()

func _on_operate_tick() -> void:
	if not input_items.is_empty():
		ensure_action(Action.OPERATE)
		output_items.append(input_items.pop_back())
	else:
		remove_action(Action.OPERATE)

func _on_io_tick() -> void:
	for side in connections:
		var m := connections[side]

		if not m.output_items.is_empty():
			ensure_action(Action.INPUT)
			input_items.append(m.output_items.pop_back())
		else:
			remove_action(Action.INPUT)
#endregion

#region hooks
func _ready() -> void:
	if name == &"Machine1":
		for i in range(10):
			input_items.append(Item.new())

	world_tick.connect(_on_world_tick)
	
	operate_tick.connect(_on_operate_tick)
	io_tick.connect(_on_io_tick)

func _process(delta: float) -> void:
	update_label()
	await get_tree().create_timer(20.0/1000).timeout
	world_tick.emit()
#endregion

func update_label():
	var text := ""
	if has_action(Action.OPERATE):
		text += "•Operate\n"
	if has_action(Action.INPUT):
		text += "•Input\n"
	if has_action(Action.OUTPUT):
		text += "•Output\n"
	if actions == 0:
		text = "None"


	$Label3D.text = text
	$ItemLabel.text = "(%s/%s)\n" % [input_items.size(), output_items.size()]
