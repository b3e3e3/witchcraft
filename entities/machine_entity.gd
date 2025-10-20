class_name MachineEntity
extends BlockEntity

func define_components() -> Array:
	return super.define_components() + [
		MachineComponent.new()
	]


func on_ready() -> void:
	super.on_ready()

	var transform := get_component(BlockTransformComponent) as BlockTransformComponent
	# var adjacent := find_adjacent_blocks()

	# for block in adjacent:
	# 	if block.has_component(BlockTransformComponent) and block.has_component(MachineComponent):
	# 		var block_pos := (block.get_component(BlockTransformComponent) as BlockTransformComponent).position
	# 		print("Found adjacent machine at %s" % block_pos)

	# 		# create relationship
	# 		if block is MachineEntity:
	# 			connect_machine(self, block)
	
	create_labels(transform)

# func connect_machine(from: MachineEntity, to: MachineEntity):
# 	if to.has_relationship(Relationships.connected):
# 		print("Already connected")
# 		return
# 	from.add_relationship(Relationship.new(ConnectedComponent.new(), to))
# 	print("Created machine relationship")

func create_labels(transform: BlockTransformComponent):
	var statuslabel := Label3D.new()
	var itemlabel := Label3D.new()
	
	add_child(statuslabel)
	add_child(itemlabel)

	statuslabel.global_position = Vector3(transform.position) + Vector3(0.6, 2, 0.5)
	statuslabel.pixel_size = 0.01
	statuslabel.text = "StatusLabel"
	statuslabel.name = "StatusLabel"

	itemlabel.global_position = Vector3(transform.position) + Vector3(0.6, 0.5, 1.5)
	itemlabel.pixel_size = 0.01
	itemlabel.text = "Itemlabel"
	itemlabel.name = "ItemLabel"
