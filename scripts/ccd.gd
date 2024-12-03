extends Node2D

@export var joint_count: int = 5
@export var segment_length: float = 150.0
@export var iterations: int = 10
@export var tolerance: float = 1.0
@onready var label: Label = $Label
@onready var h_slider: HSlider = $HSlider
@onready var lengthslider: HSlider = $lengthslider

var joints: Array[Vector2]
var smooth_factor: float = 0.05

func _ready():
	_initialize_joints()

	h_slider.min_value = 1
	h_slider.max_value = 10
	h_slider.step = 1
	h_slider.value = joint_count

	lengthslider.min_value = 50
	lengthslider.max_value = 300
	lengthslider.step = 10
	lengthslider.value = segment_length


func _process(delta):
	var mouse_pos = get_global_mouse_position() + Vector2(-900, -525)
	_ccd_ik(mouse_pos)
	_update_line()
	_update_label(mouse_pos)

func _ccd_ik(target_pos: Vector2):
	for x in range(iterations):
		for i in range(joint_count - 2, -1, -1):
			var to_effector = joints[joint_count - 1] - joints[i]
			var to_target = target_pos - joints[i]
			
			var angle = to_effector.angle_to(to_target)
			
			for j in range(i + 1, joint_count):
				joints[j] = joints[i] + (joints[j] - joints[i]).rotated(angle)

		if (joints[joint_count - 1] - target_pos).length() < tolerance:
			return

func _update_line():
	$Line2D.points = joints

func _update_label(target_pos: Vector2):
	var distance_to_target = (joints[joint_count - 1] - target_pos).length()
	var target_reached = distance_to_target < tolerance
	
	var text = "target: %s\n" % [target_pos]
	text += "distance: %.2f\n" % [distance_to_target]
	text += "iterations: %d\n" % [iterations]
	text += "target reached: %s\n" % [str(target_reached).to_lower()]

	text += "\nsegment length: %.2f\n" % [segment_length]
	text += "base position: %s\n" % [joints[0].round()]
	text += "joint positions: "
	
	var rounded_joints = []
	for joint in joints:
		rounded_joints.append(Vector2(round(joint.x), round(joint.y)))
	
	text += str(rounded_joints).to_lower()

	label.text = text

func _on_lengthslider_value_changed(value: float) -> void:
	segment_length = value
	_initialize_joints()

func _on_h_slider_value_changed(value: float) -> void:
	joint_count = int(value)
	if joint_count < 1:
		return
	_initialize_joints()


func _initialize_joints() -> void:
	joints = []
	for i in range(joint_count):
		joints.append(Vector2(i * segment_length, 0))


func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/trigonometric.tscn")
