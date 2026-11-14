
extends Node

@export var province_map_texture: Texture2D
@export var country_map_texture: Texture2D

var color_to_id: Dictionary = {}
var id_to_color: Array[Color] = []
var province_map_image: Image

# Country ownership data
var country_color_to_id: Dictionary = {}
var id_to_country_color: Array[Color] = []
var province_to_country_id: Dictionary = {}

# Review lists
var manual_review: Array = []
var unassigned_provinces: Array = []


func _ready():
	generate_province_ids()

	if country_map_texture != null:
		generate_country_ownership()


func generate_province_ids():
	if province_map_texture == null:
		push_error("Province map texture is missing!")
		return

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


func generate_country_ownership():

	if country_map_texture == null:
		push_error("Country map texture is missing!")
		return

	var country_image = country_map_texture.get_image()

	if country_image.is_compressed():
		country_image.decompress()

	# Make sure both maps have identical dimensions
	if country_image.get_width() != province_map_image.get_width() \
	or country_image.get_height() != province_map_image.get_height():
		push_error("Country map and province map dimensions do not match!")
		return

	country_color_to_id.clear()
	id_to_country_color.clear()
	province_to_country_id.clear()
	manual_review.clear()
	unassigned_provinces.clear()

	var province_country_counts: Dictionary = {}

	var width = province_map_image.get_width()
	var height = province_map_image.get_height()

	print("Starting automatic country assignment...")

	# Compare both maps pixel by pixel
	for y in range(height):
		for x in range(width):

			var province_color = province_map_image.get_pixel(x, y)

			if province_color.a < 1.0:
				continue

			var province_id = color_to_id.get(
				province_color.to_rgba32(), 0
			)

			if province_id == 0:
				continue

			var country_color = country_image.get_pixel(x, y)

			if country_color.a < 1.0:
				continue

			var country_key = country_color.to_rgba32()

			# Register unique country colors
			if not country_color_to_id.has(country_key):
				var new_country_id = id_to_country_color.size() + 1

				country_color_to_id[country_key] = new_country_id
				id_to_country_color.append(country_color)

			# Count country pixels inside each province
			if not province_country_counts.has(province_id):
				province_country_counts[province_id] = {}

			var counts = province_country_counts[province_id]

			counts[country_key] = counts.get(country_key, 0) + 1

	# Determine ownership for every province
	for province_id in range(1, id_to_color.size() + 1):

		var counts = province_country_counts.get(province_id, {})

		if counts.is_empty():

			unassigned_provinces.append(province_id)

		elif counts.size() == 1:

			var country_key = counts.keys()[0]
			var country_id = country_color_to_id[country_key]

			province_to_country_id[province_id] = country_id

		else:

			manual_review.append({
				"province_id": province_id,
				"country_counts": counts.duplicate()
			})

	# Print report
	print("")
	print("========== OWNERSHIP REPORT ==========")
	print("Total provinces: ", id_to_color.size())
	print("Countries detected: ", id_to_country_color.size())
	print("Automatically assigned: ", province_to_country_id.size())
	print("Manual review required: ", manual_review.size())
	print("Unassigned: ", unassigned_provinces.size())

	# Print provinces requiring manual review
	for entry in manual_review:

		var province_id = entry["province_id"]
		var counts = entry["country_counts"]

		var total_pixels = 0

		for country_key in counts:
			total_pixels += counts[country_key]

		print("")
		print("MANUAL REVIEW - Province ", province_id)

		for country_key in counts:

			var country_id = country_color_to_id[country_key]
			var pixels = counts[country_key]
			var percentage = float(pixels) / float(total_pixels) * 100.0

			var country_color = id_to_country_color[country_id - 1]

			print(
				"  Country ", country_id,
				" (", country_color.to_html(false), "): ",
				round(percentage * 10.0) / 10.0, "%"
			)

	print("======================================")


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


func get_country_id_for_province(province_id: int) -> int:

	return province_to_country_id.get(province_id, 0)


func get_country_color(country_id: int) -> Color:

	if country_id <= 0 or country_id > id_to_country_color.size():
		return Color.TRANSPARENT

	return id_to_country_color[country_id - 1]
