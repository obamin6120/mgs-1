
extends Sprite2D

@export var database: Node

const DRAG_THRESHOLD := 12.0

var touch_start_position := Vector2.ZERO
var is_touching := false
var is_dragging := false


func _unhandled_input(event):
	# Touchscreen input
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_position = event.position
			is_touching = true
			is_dragging = false
		else:
			if is_touching and not is_dragging:
				select_province(event.position)

			is_touching = false
			is_dragging = false

	# Detect finger movement
	elif event is InputEventScreenDrag:
		if is_touching:
			if touch_start_position.distance_to(event.position) > DRAG_THRESHOLD:
				is_dragging = true

	# Mouse input for testing
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select_province(event.position)


func select_province(screen_position: Vector2):
	if database == null:
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

	var image = texture.get_image()

	var px = int(uv.x * image.get_width())
	var py = int(uv.y * image.get_height())

	var province_id = database.get_province_id(px, py)

	if province_id != 0:
		print("Selected Province ID: ", province_id)
	else:
		print("No province found.")
