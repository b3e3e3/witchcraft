class_name MachineSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([BlockTransformComponent, MachineComponent])#.with_group("machine")

func process(entity: Entity, delta: float) -> void:
	var transform := entity.get_component(BlockTransformComponent) as BlockTransformComponent
	update_label(entity)

	var machine := entity.get_component(MachineComponent) as MachineComponent

	machine.tick_count += 1
	if machine.tick_count % 120 == 0:
		if not machine.input_items.is_empty():
			machine.ensure_action(WC.MachineAction.OPERATE)
			machine.output_items.append(machine.input_items.pop_back())
		else:
			machine.remove_action(WC.MachineAction.OPERATE)

func update_label(entity: Entity):
	var text := ""
	var machine := entity.get_component(MachineComponent) as MachineComponent

	if machine.has_action(WC.MachineAction.OPERATE):
		text += "•Operate\n"
	if machine.has_action(WC.MachineAction.INPUT):
		text += "•Input\n"
	if machine.has_action(WC.MachineAction.OUTPUT):
		text += "•Output\n"
	if machine.actions == 0:
		text = "None"


	entity.get_node(^"StatusLabel").text = text
	entity.get_node(^"ItemLabel").text = "(%s/%s)\n" % [machine.input_items.size(), machine.output_items.size()]
