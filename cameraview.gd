
extends Node2D

@onready var camera: Camera2D = $Camera2D

var dragging := false
var touches := {}
var last_pinch_distance := 0.0

func _unhandled_input(event: InputEvent) -> void:

	# MOBILE: Finger pressed or released
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			last_pinch_distance = 0.0

		if touches.size() == 2:
			last_pinch_distance = _pinch_distance()

	# MOBILE: Finger movement
	elif event is InputEventScreenDrag:
		if not touches.has(event.index):
			return

		if touches.size() == 1:
			camera.position -= event.relative / camera.zoom.x

		elif touches.size() == 2:
			touches[event.index] = event.position

			var distance = _pinch_distance()

			if last_pinch_distance > 0.0:
				zoom_map(distance / last_pinch_distance)

			last_pinch_distance = distance

	# PC TESTING: Mouse controls
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_map(0.9)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_map(1.1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	elif event is InputEventMouseMotion and dragging:
		camera.position -= event.relative / camera.zoom.x


func _pinch_distance() -> float:
	if touches.size() != 2:
		return 0.0

	var points = touches.values()
	return points[0].distance_to(points[1])


func zoom_map(amount: float) -> void:
	var new_zoom = clamp(camera.zoom.x * amount, 0.2, 4.0)
	camera.zoom = Vector2(new_zoom, new_zoom)
