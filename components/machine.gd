class_name MachineComponent
extends Component

const OPERATE_TICK_LENGTH: int = 96
const IO_TICK_LENGTH: int = 72

@export var actions: int = 0
@export var state: WC.MachineState
var tick_count: int = 0

var input_items: Array[ItemData] = [ItemData.new(), ItemData.new(), ItemData.new()]
var output_items: Array[ItemData] = []

func _init(machine_state: WC.MachineState = WC.MachineState.IDLE):
	self.state = machine_state

#region methods
func ensure_action(action: WC.MachineAction) -> void:
	if not actions & action: actions ^= action

func has_action(action: WC.MachineAction) -> bool:
	return actions & action

func remove_action(action: WC.MachineAction) -> void:
	if actions & action: actions &= ~action
#endregion
