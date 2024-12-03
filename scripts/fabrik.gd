extends Node2D

@onready var line: Line2D = $Line2D
@onready var jointSlider: HSlider = $HSlider
@onready var statusLabel: Label = $Label
@onready var smoothingToggle: CheckButton = $SmoothingToggle
@onready var smoothingStatus: Label = $smoothing
@onready var nextButton: Button = $next

@export var initial_joint_count: int = 3
@export var segment_len: float = 200.0
@export var max_iterations: int = 10
@export var distance_threshold: float = 1.0
@export var smooth_factor: float = 0.1
@export var joint_count: int

var joint_positions: Array[Vector2] = []
var segment_lengths: Array[float] = []
var apply_smoothing: bool = true

func _ready() -> void:
	initialize_joints(initial_joint_count)
	jointSlider.min_value = 1
	jointSlider.max_value = 10
	jointSlider.step = 1
	jointSlider.value = initial_joint_count
	joint_count = initial_joint_count

func initialize_joints(joint_count: int) -> void:
	segment_lengths.clear()
	joint_positions.clear()

	var base_position = global_position
	for i in range(joint_count):
		segment_lengths.append(segment_len)
		joint_positions.append(base_position + Vector2(segment_len * (i + 1), 0))
	joint_positions.append(base_position + Vector2(segment_len * joint_count, 0))

func _process(delta: float) -> void:
	var base_position = global_position
	var target_position = get_global_mouse_position()
	var target_reached = false
	var iteration_count = 0
	
	var updated_positions = joint_positions.duplicate()
	for iteration in range(max_iterations):
		updated_positions[-1] = target_position
		for i in range(joint_positions.size() - 2, -1, -1):
			var direction = (updated_positions[i] - updated_positions[i + 1]).normalized()
			updated_positions[i] = updated_positions[i + 1] + direction * segment_lengths[i]

		updated_positions[0] = base_position
		for i in range(1, joint_positions.size()):
			var direction = (updated_positions[i] - updated_positions[i - 1]).normalized()
			updated_positions[i] = updated_positions[i - 1] + direction * segment_lengths[i - 1]

		if updated_positions[-1].distance_to(target_position) < distance_threshold:
			target_reached = true
			break

		iteration_count += 1
	
	if apply_smoothing:
		for i in range(joint_positions.size()):
			joint_positions[i] = joint_positions[i].lerp(updated_positions[i], smooth_factor)
	else:
		joint_positions = updated_positions

	line.points = joint_positions.map(func(p): return p - global_position)
	
	var text = "Target: %s\n" % [target_position]
	var distance_to_target = joint_positions[-1].distance_to(target_position)
	text += "Distance: %.2f\n" % [distance_to_target]
	text += "Iterations: %d\n" % [iteration_count]
	text += "Target Reached: %s\n" % [str(target_reached).to_lower()]

	text += "\nSegment Length: %.2f\n" % [segment_len]
	text += "\nSegment Count: %s\n" % [joint_count]
	text += "Base Position: %s\n" % [base_position.round()]
	text += "Joint Positions: "
	
	var rounded_joints = []
	for joint in joint_positions:
		rounded_joints.append(Vector2(round(joint.x), round(joint.y)))
	
	text += str(rounded_joints).to_lower()

	statusLabel.text = text.to_lower()

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ccd.tscn")


func _on_lengthslider_value_changed(value: float) -> void:
	segment_len = value
	initialize_joints(joint_count)

func _on_applysmoothing_toggled(toggled_on: bool) -> void:
	apply_smoothing = toggled_on
	smoothingStatus.text = "Apply Smoothing: " + str(apply_smoothing)


func _on_h_slider_value_changed(value: float) -> void:
	joint_count = int(value)
	if joint_count < 1:
		return
	
	initialize_joints(joint_count)
