extends Node2D

@export var arm1_length: float = 300.0
@export var arm2_length: float = 300.0
@onready var display_label: Label = $Label
@onready var line: Line2D = $Line2D

func _process(delta: float) -> void:
	var target_pos = get_global_mouse_position()
	
	var direction = target_pos - global_position
	var distance = direction.length()
	distance = min(distance, arm1_length + arm2_length)

	var angle2_cos = clamp((arm1_length * arm1_length + arm2_length * arm2_length - distance
	* distance) / (2 * arm1_length * arm2_length), -1, 1)
	var angle2 = acos(angle2_cos)

	var angle1_cos = clamp((arm1_length * arm1_length + distance * distance - arm2_length
	* arm2_length) / (2 * arm1_length * distance), -1, 1)
	var angle1 = acos(angle1_cos)
	display_label.global_position = target_pos + Vector2(25, 25)
	display_label.text = "Target: %s \nDistance: %.2f" % [round(target_pos), round(distance)]
	var base_angle = direction.angle()

	var arm1_rotation = base_angle - angle1
	var arm1_end = Vector2(arm1_length, 0).rotated(arm1_rotation)

	var arm2_rotation = arm1_rotation - angle2
	var arm2_end = arm1_end - Vector2(arm2_length, 0).rotated(arm2_rotation)

	line.points = [Vector2.ZERO, arm1_end, arm2_end]
	
	display_label.text += "\nBase Angle: %.2f \nAngle 1: %.2f \nAngle 2: %.2f" % [
		round(rad_to_deg(base_angle)), round(rad_to_deg(angle1)), round(rad_to_deg(angle2))
	]
	display_label.text += "\nArm 1 Rotation: %.2f \nArm 2 Rotation: %.2f" % [
		round(rad_to_deg(arm1_rotation)), round(rad_to_deg(arm2_rotation))
	]
	display_label.text = display_label.text.to_lower()

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/fabrik.tscn")
