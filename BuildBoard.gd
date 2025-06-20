extends Node

var tileMap = get_node("HexGrid")

func load_tile_map(path: String):
	var coordinates_array: Array
	var file = FileAccess.open(path, FileAccess.READ)
	
	while not file.eof_reached():
		var line = file.get_line()
		var piece = line.split(",")
		var x = int(piece[0])
		var y = int(piece[1])
		coordinates_array.append(Vector2i(x, y))
		
	return coordinates_array

func place_tiles(coordinates: Array[Vector2i]):
	
