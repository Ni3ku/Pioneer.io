extends TileMapLayer

func load_tile_map(path: String):
	var coordinates_array: Array[Vector2i]
	var file = FileAccess.open(path, FileAccess.READ)
	
	while not file.eof_reached():
		var line = file.get_line()
		var piece = line.split(",")
		if piece.size() == 2:
			var x = int(piece[0])
			var y = int(piece[1])
			coordinates_array.append(Vector2i(x, y))
		
	return coordinates_array

func randomize_resources(coordinates_array: Array[Vector2i]):
	var leftover = coordinates_array.size() % 5 - 1
	var distrobution = floor(coordinates_array.size() / 5)
	var current_resource = 1
	coordinates_array.shuffle()
	for resource in 5:
		for i in distrobution:
			set_cell(coordinates_array[i], current_resource, Vector2i(0,0))
			coordinates_array.remove_at(i)
		current_resource += 1
	set_cell(coordinates_array[0], 6, Vector2i(0,0))
	coordinates_array.remove_at(0)
	var i = 1
	for final_set in leftover:
		set_cell(coordinates_array[final_set], i, Vector2i(0,0))
		i += 1

func _ready() -> void:
	var coords = load_tile_map("res://Default.txt")
	randomize_resources(coords)
