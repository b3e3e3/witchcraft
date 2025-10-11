class_name MachineComponent
extends Component

const OPERATE_TICK_LENGTH: int = 96
const IO_TICK_LENGTH: int = 72

@export var actions: int = 0
@export var state: Global.MachineState
var tick_count: int = 0
class Item:
	var name: String = "Item"

var input_items: Array[Item] = [Item.new(), Item.new(), Item.new()]
var output_items: Array[Item] = []

func _init(machine_state: Global.MachineState = Global.MachineState.IDLE):
	self.state = machine_state

#region methods
func ensure_action(action: Global.MachineAction) -> void:
	if not actions & action: actions ^= action

func has_action(action: Global.MachineAction) -> bool:
	return actions & action

func remove_action(action: Global.MachineAction) -> void:
	if actions & action: actions &= ~action
#endregion