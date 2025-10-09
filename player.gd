class_name Player
extends CharacterBody3D

const SPRINT_FOV_MULT: float = 0.3
const SPRINT_SPEED_MULT: float = 0.3
const SPRINT_BOB_MULT: Vector2 = Vector2(0, 0.08)

const WALK_BOB_MULT: Vector2 = Vector2(0, 0.06)


@export var speed: float = 8 # m/s
@export var acceleration: float = 100 # m/s^2

@export var jump_height: float = 1.5 # m
@export var camera_sens: float = 1

var waiting_for_fly: bool = false
var flying: bool = false

var jumping: bool = false
var sprinting: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var look_dir: Vector2
var move_dir: Vector2

var walk_vel: Vector3
var fly_vel: Vector3
var sprint_vel: Vector3
var grav_vel: Vector3
var jump_vel: Vector3

# #region voxels
# @onready var terrain: VoxelTerrain = $"../VoxelTerrain"
# @onready var voxel_tool = terrain.get_voxel_tool()
# #endregion

@onready var camera: Camera3D = $Camera
@onready var camera_base_fov: float = camera.fov
var fov_offset: float
var camera_bob_counter: float
var bob_amount: float = 0.0

@onready var block_highlight: MeshInstance3D = MeshInstance3D.new()

func setup_hightlight() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://outline.gdshader")
	# mat.set_shader_parameter(&"outline_width", 2.0)
	
	var box := BoxMesh.new()
	box.size = Vector3.ONE * 1.01
	
	box.material = mat
	block_highlight.mesh = box

	add_child(block_highlight)

func _ready() -> void:
	setup_hightlight()
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed(&"exit"):
		release_mouse()

func _camera_bob(delta: float) -> void:
	var _mult := WALK_BOB_MULT if not sprinting else SPRINT_BOB_MULT
	# var _speed := WALK_BOB_SPEED if not sprinting else SPRINT_BOB_SPEED
	
	var _target_h := cos(camera_bob_counter / 2) * _mult.x
	var _target_v := -sin(camera_bob_counter) * _mult.y

	var _should_bob := not velocity.is_zero_approx() and is_on_floor()
	bob_amount = lerpf(bob_amount, 1.0 if _should_bob else 0.0, delta * 8)
	camera_bob_counter += delta * velocity.length() * 2.4
	camera.v_offset = _target_v * bob_amount
	camera.h_offset = _target_h * bob_amount

# func _break_blocks(target_pos: Vector3i) -> void:
# 	if Input.is_action_just_pressed(&"break"):
# 		voxel_tool.mode = VoxelTool.MODE_REMOVE
# 		voxel_tool.do_point(target_pos)

# func _place_blocks(target_pos: Vector3i, normal: Vector3) -> void:
# 	if Input.is_action_just_pressed(&"interact"):
# 		voxel_tool.mode = VoxelTool.MODE_ADD
# 		print("add")
# 		voxel_tool.set_voxel(target_pos + Vector3i(normal), 1)

func _hightlight_blocks(rc: VoxelRaycastResult):
	if rc:
		block_highlight.visible = true
		block_highlight.global_position = (rc.position as Vector3) + (Vector3.ONE * 0.5)
	else:
		block_highlight.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		var space_state = get_world_3d().direct_space_state
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 5.0

		var query = PhysicsRayQueryParameters3D.create(from, to)

		var result = space_state.intersect_ray(query)

func _process(delta: float) -> void: pass
# 	var rc := voxel_tool.raycast(camera.global_position, -camera.global_basis.z, 5.0)
# 	_hightlight_blocks(rc)
# 	if rc:
# 		var target_pos := rc.position

# 		_break_blocks(target_pos)
# 		_place_blocks(target_pos, rc.normal)
		
func _wait_for_fly() -> void:
	await get_tree().create_timer(0.3).timeout
	waiting_for_fly = false

func tween_fov(time: float = 0.5) -> void:
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(camera, ^'fov', camera_base_fov + fov_offset, time)

func _physics_process(delta: float) -> void:
	_camera_bob(delta)

	if Input.is_action_just_pressed(&"jump"):
		jumping = true
		if waiting_for_fly:
			fov_offset += camera.fov * SPRINT_FOV_MULT
			flying = not flying
		else:
			waiting_for_fly = true
			_wait_for_fly()
	
	if Input.is_action_pressed(&"sprint"):
		if not sprinting and not is_zero_approx(velocity.x):
			# camera_base_fov = camera.fov
			
			fov_offset += camera.fov * SPRINT_FOV_MULT
			sprinting = true
	elif Input.is_action_just_released(&"sprint"):
		print(sprinting)
		print(velocity)
		fov_offset = 0
		tween_fov()
	else:
		sprinting = false

	tween_fov()

	if not sprinting and not flying:
		fov_offset = 0
	
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	
	motion_mode = MOTION_MODE_FLOATING if flying else MOTION_MODE_GROUNDED

	velocity = _walk(delta) + _gravity(delta) + _jump(delta) + _sprint(delta) + _fly(delta)
	move_and_slide()

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float):
	move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float):
	grav_vel = Vector3.ZERO if is_on_floor() or flying else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel
	
func _fly(delta: float):
	fly_vel = Vector3.ZERO

	if flying:
		fly_vel = Vector3.UP * Input.get_axis(&"sneak", &"jump") * 10
		if is_on_floor():
			flying = false
	return fly_vel

func _jump(delta: float):
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _sprint(delta: float):
	if sprinting:
		# camera.fov = camera_base_fov * 1.8
		return walk_vel * SPRINT_SPEED_MULT

	# camera.fov = camera_base_fov	
	return Vector3.ZERO

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
