
extends Sprite2D

@export var database: Node

const DRAG_THRESHOLD := 12.0
const TOUCH_MOUSE_DELAY := 400

# Touchscreen tracking
var touches := {}
var touch_start_position := Vector2.ZERO
var touch_candidate_index := -1
var touch_moved := false
var multi_touch := false
var last_touch_time := -1000

# Mouse tracking for PC testing
var mouse_down := false
var mouse_start_position := Vector2.ZERO
var mouse_moved := false


func _input(event: InputEvent) -> void:

	# MOBILE: Finger pressed or released
	if event is InputEventScreenTouch:

		if event.pressed:
			touches[event.index] = event.position

			if touches.size() == 1:
				touch_candidate_index = event.index
				touch_start_position = event.position
				touch_moved = false
				multi_touch = false
			else:
				multi_touch = true
				touch_candidate_index = -1

		else:
			if event.index == touch_candidate_index:
				if not touch_moved and not multi_touch:
					last_touch_time = Time.get_ticks_msec()
					select_province(event.position)

			touches.erase(event.index)

			if touches.is_empty():
				touch_candidate_index = -1
				touch_moved = false
				multi_touch = false

	# MOBILE: Finger movement
	elif event is InputEventScreenDrag:
		if touches.has(event.index):
			touches[event.index] = event.position

			if touch_start_position.distance_to(event.position) > DRAG_THRESHOLD:
				touch_moved = true

			if touches.size() > 1:
				multi_touch = true

	# PC: Mouse click
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if Time.get_ticks_msec() - last_touch_time < TOUCH_MOUSE_DELAY:
				return

			if event.pressed:
				mouse_down = true
				mouse_start_position = event.position
				mouse_moved = false
			else:
				if mouse_down and not mouse_moved:
					select_province(event.position)

				mouse_down = false

	# PC: Mouse movement
	elif event is InputEventMouseMotion and mouse_down:
		if mouse_start_position.distance_to(event.position) > DRAG_THRESHOLD:
			mouse_moved = true


func select_province(screen_position: Vector2) -> void:
	if database == null:
		push_warning("Province database is not assigned!")
		return

	if texture == null:
		push_warning("Province map texture is missing!")
		return

	var local_position = get_global_transform_with_canvas().affine_inverse() * screen_position
	var rect = get_rect()

	if not rect.has_point(local_position):
		return

	var uv = (local_position - rect.position) / rect.size

	if flip_h:
		uv.x = 1.0 - uv.x
	if flip_v:
		uv.y = 1.0 - uv.y


	var px = int(uv.x * texture.get_width())
	var py = int(uv.y * texture.get_height())

	var province_id = database.get_province_id(px, py)

	if province_id != 0:
		print("Selected Province ID: ", province_id)

		# HIGHLIGHT SELECTED PROVINCE
		var shader_material := material as ShaderMaterial

		if shader_material:
			shader_material.set_shader_parameter(
				"selected_color",
				database.get_province_color(province_id)
			)

			shader_material.set_shader_parameter(
				"has_selection",
				true
			)
		else:
			push_warning("No ShaderMaterial found on Sprite2D!")

	else:
		print("No province found.")
