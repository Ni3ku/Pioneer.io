extends Node2D

const brick = 1
const ore = 2
const sheep = 3
const wheat = 4
const wood = 5
const desert = 6
const number_tile_set = [2,3,4,5,6,8,9,10,11,12]

var neighbor_directions = [
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
]

@onready
var tile_grid = $HexGrid

@onready
var number_Grid = $NumberGrid

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
	var preserved_coordinates: Array[Vector2i]
	var shuffled_coordinates = coordinates_array.duplicate()
	shuffled_coordinates.shuffle()
	for resource in 5:
		for i in distrobution:
			tile_grid.set_cell(shuffled_coordinates[i], current_resource, Vector2i(0,0))
			shuffled_coordinates.remove_at(i)
		current_resource += 1
	tile_grid.set_cell(shuffled_coordinates[0], 6, Vector2i(0,0))
	shuffled_coordinates.remove_at(0)
	var i = 1
	for final_set in leftover:
		tile_grid.set_cell(shuffled_coordinates[final_set], i, Vector2i(0,0))
		i += 1

func randomize_numbers(coordinates_array: Array[Vector2i]):
	var overflow = coordinates_array.size() % 10 - 1
	var number_distrobution = floor(coordinates_array.size() / 10)
	var shuffled_coordinates = coordinates_array.duplicate()
	shuffled_coordinates.shuffle()
	number_tile_set.shuffle()
	for i in range(number_distrobution):
		for j in number_tile_set:
			if tile_grid.get_cell_source_id(shuffled_coordinates[i]) != 6:
				number_Grid.set_cell(shuffled_coordinates[i], j, Vector2i(0,0))
			shuffled_coordinates.remove_at(i)
	for i in range(overflow , -1, -1):
		if tile_grid.get_cell_source_id(shuffled_coordinates[i]) != 6:
			number_Grid.set_cell(shuffled_coordinates[i], number_tile_set[i], Vector2i(0,0))
		shuffled_coordinates.remove_at(i)

func get_neighbors(tilemap: TileMapLayer, coord: Vector2i):
	var neighbors = []
	for dir in neighbor_directions:
		neighbors.append(tilemap.get_neighbor_cell(coord, dir))
	return neighbors

func sort_numbers(coordinates_array: Array[Vector2i]):
	var tile_ids = []
	for coord in coordinates_array:
		tile_ids.append(number_Grid.get_cell_source_id(coord))
	
	var max_attempts = coordinates_array.size() * 2
	var attempts = 0;
	
	while attempts < max_attempts:
		var had_conflicts = false
		
		for i in coordinates_array.size():
			var current_id = tile_ids[i]
			var neighbours = get_neighbors(number_Grid, coordinates_array[i])
			
			for neighbour_coord in neighbours:
				var neighbour_index = coordinates_array.find(neighbour_coord)
				if (neighbour_index != -1 and tile_ids[neighbour_index] == current_id) or ((current_id == 6 or current_id == 8) and (tile_ids[neighbour_index] == 6 or tile_ids[neighbour_index] == 8)):
					had_conflicts = true
					
					for j in range(coordinates_array.size() - 1, -1, -1):
						if i == j:
							continue
							
						var potential_id = tile_ids[j]
						var is_good_swap = true
						
						var j_neighbours = get_neighbors(number_Grid, coordinates_array[j])
						for j_neighbour in j_neighbours:
							var j_neighbour_index = coordinates_array.find(j_neighbour)
							if (j_neighbour_index != -1 and tile_ids[j_neighbour_index] == current_id) or ((current_id == 6 or current_id == 8) and (tile_ids[j_neighbour_index] == 6 or tile_ids[j_neighbour_index] == 8)):
								
								is_good_swap = false
								break
							
						if is_good_swap:
							tile_ids[i] = potential_id
							tile_ids[j] = current_id
							break
							
					break
					
		if not had_conflicts:
			for i in range(coordinates_array.size()):
				number_Grid.set_cell(coordinates_array[i], tile_ids[i], Vector2i(0,0))
			return
		attempts += 1
		
	for i in range(coordinates_array.size()):
		number_Grid.set_cell(coordinates_array[i], tile_ids[i], Vector2i(0,0))
	print("Could not resolve conflicts")

func validate_number_grid(coords: Array[Vector2i]) -> bool:
	for i in coords.size():
		var id = number_Grid.get_cell_source_id(coords[i])
		var neighbors = get_neighbors(number_Grid, coords[i])
		for neighbor in neighbors:
			var neighbor_index = coords.find(neighbor)
			if neighbor_index == -1:
				continue
			var neighbor_id = number_Grid.get_cell_source_id(coords[neighbor_index])
			if neighbor_id == id:
				return false
			if (id == 6 or id == 8) and (neighbor_id == 6 or neighbor_id == 8):
				return false
	return true

func _ready() -> void:
	var coords = load_tile_map("res://Default.txt")
	var success = false
	var max_attempts = 10
	
	for i in range(max_attempts):
		randomize_resources(coords)
		randomize_numbers(coords)
		sort_numbers(coords)
		if validate_number_grid(coords):
			success = true
			break
	
	if not success:
		print("Could not resolve conflicts")
