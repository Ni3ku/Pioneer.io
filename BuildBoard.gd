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

func get_neighbors(tilemap: TileMapLayer, coord: Vector2i):
	var neighbors = []
	for dir in neighbor_directions:
		neighbors.append(tilemap.get_neighbor_cell(coord, dir))
	return neighbors

func sort_numbers(coordinates_array: Array[Vector2i]):
	var tile_ids = []
	var coordinateTile = []
	var is_good_swap = false
	for coord in range(coordinates_array.size()):
		tile_ids.append(number_Grid.get_cell_source_id(coordinates_array[coord]))

		
	for i in range(coordinates_array.size()):
		is_good_swap = false
		var current_id = tile_ids[i]
		if current_id != -1:
			var i_neighbours = number_Grid.get_surrounding_cells(coordinates_array[i])
			var i_nighbour_ids = []
			
			for i_neighbour in i_neighbours:
				i_nighbour_ids.append(%NumberGrid.get_cell_source_id(i_neighbour))
			##print("is")
			#print(current_id)
			###neighbours)
			#print(i_nighbour_ids)
			
			if (current_id in i_nighbour_ids):
				print("condition 1 ", current_id, coordinates_array[i], i_nighbour_ids)
				is_good_swap = true
			if  ((current_id == 6 and 8 in i_nighbour_ids)):
				print("condition 2 ", current_id, coordinates_array[i], i_nighbour_ids)
				is_good_swap = true
			if ((current_id == 8 and 6 in i_nighbour_ids)):
				print("condition 3 ", current_id, coordinates_array[i], i_nighbour_ids)
				is_good_swap = true
			
			if is_good_swap:
				for j in range(coordinates_array.size()):
					is_good_swap = true
					
					var potential_id = tile_ids[j]
					if potential_id != -1:	
						var j_neighbours = number_Grid.get_surrounding_cells(coordinates_array[j])
						var j_nighbour_ids = []

						for j_neighbour in j_neighbours:
							j_nighbour_ids.append(number_Grid.get_cell_source_id(j_neighbour))
						#print("js")
						#print(potential_id)
						##neighbours)
						#print(j_nighbour_ids)
								
						if (potential_id in i_nighbour_ids):
							print("condition 1j ", potential_id, coordinates_array[j], j_nighbour_ids)
							is_good_swap = false
						if (current_id in j_nighbour_ids):
							print("condition 2j ", potential_id, coordinates_array[j], j_nighbour_ids)
							is_good_swap = false
						if (current_id == 6):
							if 8 in j_nighbour_ids:
								print("condition 3j" , potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
							if 6 in j_nighbour_ids:
								print("condition 4j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
						if (current_id == 8):
							if 8 in j_nighbour_ids:
								print("condition 5j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
							if 6 in j_nighbour_ids:
								print("condition 6j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
						if (potential_id == 8):
							if 8 in i_nighbour_ids:
								print("condition 7j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
							if 6 in i_nighbour_ids:
								print("condition 8j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
						if (potential_id == 6):
							if 8 in i_nighbour_ids:
								print("condition 9j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
							if 6 in i_nighbour_ids:
								print("condition 10j ", potential_id, coordinates_array[j], j_nighbour_ids)
								is_good_swap = false
						if current_id == potential_id:
							print("condition 11j " , potential_id, coordinates_array[j], j_nighbour_ids)
							is_good_swap = false
								
						if is_good_swap:
							#print("needs work!")
							var temp = tile_ids[i]
							tile_ids[i] = tile_ids[j]
							tile_ids[j] = temp
							number_Grid.set_cell(coordinates_array[i], tile_ids[i], Vector2i(0,0))
							number_Grid.set_cell(coordinates_array[j], tile_ids[j], Vector2i(0,0))
							print("swapped! ",potential_id, coordinates_array[j], j_nighbour_ids)
							is_good_swap = false
							break
				
	#print(coordinates_array)
	for final_tile_id in range(tile_ids.size()):
		number_Grid.set_cell(coordinates_array[final_tile_id], tile_ids[final_tile_id], Vector2i(0,0))
			
func validate_number_grid(coords: Array[Vector2i]) -> bool:
	for i in range(coords.size()):
		var coord = coords[i]
		var number_id = number_Grid.get_cell_source_id(coord)
		if number_id == -1:
			continue

		var neighbours = get_neighbors(number_Grid, coord)
		for neighbour in neighbours:
			if not coords.has(neighbour):
				continue 

			var neighbour_id = number_Grid.get_cell_source_id(neighbour)
			if neighbour_id == -1:
				continue

			if number_id == neighbour_id:
				return false

			if (number_id == 6 or number_id == 8) and (neighbour_id == 6 or neighbour_id == 8):
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
