class_name Machine
extends StaticBody3D

signal tick

const TICK_LENGTH: float = 0.05
const OPERATE_LENGTH: int = 100

enum State {
	IDLE,
	OPERATE,
	INPUT,
	OUTPUT,
}

var input_enabled: bool = true
var output_enabled: bool = true

var input_items: int = 10
var output_items: int = 0

var tick_count: int = 0

func operate() -> void:
	if input_items > 0:
		input_items -= 1
		output_items += 1
		print("%s Operating... (%d/%d)" % [name, input_items, output_items])
	else:
		print("Done")

# TODO: standardized tick system
func _on_tick() -> void:
	tick_count += 1

	if tick_count % OPERATE_LENGTH == 0:
		operate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tick.connect(_on_tick)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tick.emit()
	await get_tree().create_timer(TICK_LENGTH).timeout
