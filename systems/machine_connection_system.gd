class_name MachineConnectionSystem
extends System

func query() -> QueryBuilder:
	return q.with_relationship([Relationships.connected])


