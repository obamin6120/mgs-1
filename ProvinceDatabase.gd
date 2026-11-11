extends Node

@export var province_map_texture: Texture2D

var color_to_id: Dictionary = {}
var id_to_color: Array[Color] = []

func _ready():
	generate_province_ids()


func generate_province_ids():
	if province_map_texture == null:
		push_error("Province map texture is missing!")
		return

	var img = province_map_texture.get_image()

	if img.is_compressed():
		img.decompress()

	color_to_id.clear()
	id_to_color.clear()

	var width = img.get_width()
	var height = img.get_height()

	for y in range(height):
		for x in range(width):
			var color = img.get_pixel(x, y)

			# Ignore transparent pixels
			if color.a < 1.0:
				continue

			var key = color.to_rgba32()

			if not color_to_id.has(key):
				var new_id = id_to_color.size() + 1

				color_to_id[key] = new_id
				id_to_color.append(color)

	print("Province scan complete!")
	print("Unique colors found: ", id_to_color.size())


func get_province_id(x: int, y: int) -> int:
	var img = province_map_texture.get_image()

	if x < 0 or x >= img.get_width():
		return 0

	if y < 0 or y >= img.get_height():
		return 0

	var color = img.get_pixel(x, y)

	return color_to_id.get(color.to_rgba32(), 0)


func get_province_color(province_id: int) -> Color:
	if province_id <= 0 or province_id > id_to_color.size():
		return Color.TRANSPARENT

	return id_to_color[province_id - 1]
