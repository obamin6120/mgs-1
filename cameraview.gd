
extends Node2D

@onready var camera: Camera2D = $Camera2D

const MIN_ZOOM := 0.2
const MAX_ZOOM := 4.0

var touches: Dictionary = {}
var dragging := false
var last_mouse_position := Vector2.ZERO
var last_pinch_distance := 0.0


func _unhandled_input(event: InputEvent) -> void:

	# TOUCHSCREEN: Finger pressed or released
	if event is InputEventScreenTouch:

		if event.pressed:
			touches[event.index] = event.position

			# Reset pinch tracking when two fingers are present
			if touches.size() == 2:
				last_pinch_distance = _pinch_distance()

		else:
			touches.erase(event.index)

			if touches.size() < 2:
				last_pinch_distance = 0.0

	# TOUCHSCREEN: Finger movement
	elif event is InputEventScreenDrag:

		if not touches.has(event.index):
			return

		var previous_position: Vector2 = touches[event.index]
		touches[event.index] = event.position

		if touches.size() == 1:
			# Direct one-finger movement
			var movement = event.position - previous_position
			camera.position -= movement / camera.zoom.x

		elif touches.size() == 2:
			# Two-finger pinch zoom
			var new_distance = _pinch_distance()

			if last_pinch_distance > 0.0:
				var zoom_factor = new_distance / last_pinch_distance
				zoom_map(zoom_factor)

			last_pinch_distance = new_distance

	# MOUSE: PC testing
	elif event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_position = event.position

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_map(0.9)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_map(1.1)

	elif event is InputEventMouseMotion and dragging:

		var movement = event.position - last_mouse_position
		camera.position -= movement / camera.zoom.x
		last_mouse_position = event.position


func _pinch_distance() -> float:

	if touches.size() != 2:
		return 0.0

	var points = touches.values()
	return points[0].distance_to(points[1])


func zoom_map(amount: float) -> void:

	var new_zoom = clamp(
		camera.zoom.x * amount,
		MIN_ZOOM,
		MAX_ZOOM
	)

	camera.zoom = Vector2(new_zoom, new_zoom)
