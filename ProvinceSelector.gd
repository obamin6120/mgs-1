
extends Sprite2D

@export var database: Node

func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		select_province(event.position)

	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select_province(event.position)


func select_province(screen_position: Vector2):
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
