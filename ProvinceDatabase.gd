
extends Node

@export var province_map_texture: Texture2D

var color_to_id: Dictionary = {}
var id_to_color: Array[Color] = []
var province_map_image: Image


func _ready():
	generate_province_ids()


func generate_province_ids():
	if province_map_texture == null:
		push_error("Province map texture is missing!")
		return

	# Load the image ONCE and keep it cached
	province_map_image = province_map_texture.get_image()

	if province_map_image.is_compressed():
		province_map_image.decompress()

	color_to_id.clear()
	id_to_color.clear()

	var width = province_map_image.get_width()
	var height = province_map_image.get_height()

	for y in range(height):
		for x in range(width):
			var color = province_map_image.get_pixel(x, y)

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
	if province_map_image == null:
		return 0

	if x < 0 or x >= province_map_image.get_width():
		return 0

	if y < 0 or y >= province_map_image.get_height():
		return 0

	var color = province_map_image.get_pixel(x, y)

	return color_to_id.get(color.to_rgba32(), 0)


func get_province_color(province_id: int) -> Color:
	if province_id <= 0 or province_id > id_to_color.size():
		return Color.TRANSPARENT

	return id_to_color[province_id - 1]
