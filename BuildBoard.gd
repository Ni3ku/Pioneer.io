extends Node2D

var resource_dictionary = {
	1: "wood",
 	2: "brick",
 	3: "sheep",
 	4: "wheat",
 	5: "Ore",
}

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
	var file = FileAccess.open(path, FileAccess.READ)
	var resource_array = str_to_var(file.get_line())
	return resource_array

func convert_to_lower_vector(vector3_array: Array[Vector3i]) -> Array[Vector2i]:
	var vector2_array: Array[Vector2i]
	for element in vector3_array:
		vector2_array.append(Vector2i(element.x, element.y))
	return vector2_array

func place_preset_resources(coordinates_array: Array[Vector3i]):
	for preset_resource in coordinates_array:
		if preset_resource.z != 0:
			tile_grid.set_cell(Vector2i(preset_resource.x, preset_resource.y), preset_resource.z, Vector2i(0,0))

func randomize_resources(coordinates_array: Array[Vector3i]):
	var undetermined_resource_vectors: Array[Vector2i]
	var desert_count = 0
	for resource in coordinates_array:
		if resource.z == 0:
			undetermined_resource_vectors.append(Vector2i(resource.x, resource.y))
		if resource.z == 6:
			desert_count += 1

	var leftover = undetermined_resource_vectors.size() % 5
	var distrobution = floor(undetermined_resource_vectors.size() / 5)
	var current_resource = 1
	var preserved_coordinates: Array[Vector2i]
	var shuffled_coordinates = undetermined_resource_vectors.duplicate()
	shuffled_coordinates.shuffle()
	for resource in resource_dictionary.keys():
		for i in range(distrobution - 1, -1, -1):
			tile_grid.set_cell(shuffled_coordinates[i], resource, Vector2i(0,0))
			shuffled_coordinates.remove_at(i)
	var i = 1
	for final_set in leftover:
		tile_grid.set_cell(shuffled_coordinates[final_set], i, Vector2i(0,0))
		i += 1
	if desert_count == 0:
		tile_grid.set_cell(shuffled_coordinates[0], 6, Vector2i(0,0))

func randomize_numbers(coordinates_array: Array[Vector3i]):
	for resource in range(coordinates_array.size() - 1, -1, -1):
		if coordinates_array[resource].z == 6:
			coordinates_array.remove_at(resource)
	
	var two_dimensional_coordinates_array = convert_to_lower_vector(coordinates_array)
	
	var overflow = two_dimensional_coordinates_array.size() % number_tile_set.size()
	var number_distrobution = floor(two_dimensional_coordinates_array.size() / number_tile_set.size())
	
	var shuffled_coordinates = two_dimensional_coordinates_array.duplicate()
	shuffled_coordinates.shuffle()
	var shuffled_number_set = number_tile_set.duplicate()
	shuffled_number_set.shuffle()
	
	for i in range(number_distrobution):
		for j in range(number_tile_set.size()):
			if tile_grid.get_cell_source_id(shuffled_coordinates[0]) != 6:
				number_Grid.set_cell(shuffled_coordinates[0], shuffled_number_set[j], Vector2i(0,0))
			shuffled_coordinates.remove_at(0)
	for i in range(overflow):
		if tile_grid.get_cell_source_id(shuffled_coordinates[0]) != 6:
			number_Grid.set_cell(shuffled_coordinates[0], number_tile_set[i], Vector2i(0,0))
		shuffled_coordinates.remove_at(0)

#func get_neighbors(tilemap: TileMapLayer, coord: Vector2i):
	#var neighbors = []
	#for dir in neighbor_directions:
		#neighbors.append(tilemap.get_neighbor_cell(coord, dir))
	#return neighbors

func sort_numbers(coordinates_array: Array[Vector2i]):
	var tile_ids = []
	for coord in range(coordinates_array.size() - 1, -1, -1):
		if number_Grid.get_cell_source_id(coordinates_array[coord]) != -1:
			tile_ids.append(number_Grid.get_cell_source_id(coordinates_array[coord]))
		else:
			coordinates_array.remove_at(coord)
			
	var shuffled_coordinate_array= coordinates_array.duplicate()
	shuffled_coordinate_array.shuffle()
		
	for i in range(tile_ids.size()):
		var current_id = tile_ids[i]
		var i_neighbours = number_Grid.get_surrounding_cells(shuffled_coordinate_array[i])
		var i_nighbour_ids = []
		
		for i_neighbour in i_neighbours:
			i_nighbour_ids.append(number_Grid.get_cell_source_id(i_neighbour))
		
		for i_nighbour_id in i_nighbour_ids:
			if (i_nighbour_id == current_id or ((current_id == 6 or current_id == 8) and (i_nighbour_id == 6 or i_nighbour_id == 8))):
				var is_good_swap = true
			
				for j in range(tile_ids.size()):
						
					var potential_id = tile_ids[j]
					is_good_swap = true
					
					var j_neighbours = number_Grid.get_surrounding_cells(shuffled_coordinate_array[j])
					var j_nighbour_ids = []

					for j_neighbour in j_neighbours:
						j_nighbour_ids.append(number_Grid.get_cell_source_id(j_neighbour))
						
					if (potential_id in i_nighbour_ids or current_id in j_nighbour_ids):
						is_good_swap = false
						break
						
					if is_good_swap:
						number_Grid.set_cell(shuffled_coordinate_array[i], potential_id, Vector2i(0,0))
						print(shuffled_coordinate_array[i])
						print(potential_id)
						number_Grid.set_cell(shuffled_coordinate_array[j], current_id, Vector2i(0,0))
						print(shuffled_coordinate_array[j])
						print(current_id)
						
func validate_number_grid(coords: Array[Vector2i]) -> bool:
	for i in coords.size():
		var number_id = number_Grid.get_cell_source_id(coords[i])
		var neighbors = number_Grid.get_surrounding_cells(coords[i])
		if number_id in neighbors:
			return false
		if ((number_id == 6 or number_id == 8) and (6 in neighbors or 8 in neighbors)):
			return false
	return true

func _ready() -> void:
	var three_dimensional_coords = load_tile_map("res://test (1).txt")
	var two_dimensional_coords = convert_to_lower_vector(three_dimensional_coords)
	var success = false
	var max_attempts = 1

	
	place_preset_resources(three_dimensional_coords)
	randomize_resources(three_dimensional_coords)
	randomize_numbers(three_dimensional_coords)
	
	for i in range(max_attempts):
		sort_numbers(two_dimensional_coords)
		if validate_number_grid(two_dimensional_coords):
			success = true
			break
	
	if not success:
		print("Could not resolve conflicts")
